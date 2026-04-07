;;; ============================================================================
;;; PolyDimension.lsp
;;;
;;; Places aligned dimensions along a polyline at every vertex and at every
;;; intersection with a user-selected set of entities.
;;;
;;; Command:    PolyDimension
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:polydimension (/ polyent osnap intersections entities pt1 pt2
                          i ent inters j pt vertices)
  ;; Save and reset system variables
  (setq osnap (getvar "OSMODE"))
  (setvar "OSMODE" 0)
  
  ;; Select polyline to dimension
  (princ "\nSelect polyline to dimension: ")
  (setq polyent (car (entsel)))
  
  ;; Validate selection
  (if (or (null polyent)
          (not (wcmatch (cdr (assoc 0 (entget polyent))) "*POLYLINE")))
    (progn
      (setvar "OSMODE" osnap)
      (princ "\nYou must select a polyline.")
      (exit)
    )
  )
  
  ;; Select entities to check for intersections
  (princ "\nSelect objects to check for intersections: ")
  (setq entities (ssget))
  
  ;; Find intersections
  (setq intersections (list))
  
  ;; Process each selected entity
  (if entities
    (progn
      (setq i 0)
      (repeat (sslength entities)
        (setq ent (ssname entities i))
        ;; Skip if entity is our polyline
        (if (/= ent polyent)
          (progn
            ;; Use VLA objects for intersection
            (setq inters (vla-intersectwith 
                           (vlax-ename->vla-object polyent)
                           (vlax-ename->vla-object ent)
                           acExtendNone))
            
            ;; Process intersection points if any found
            (if inters
              (progn
                (setq j 0)
                (repeat (/ (vlax-safearray-get-u-bound inters 1) 3)
                  (setq pt (list (vlax-safearray-get-element inters j)
                                (vlax-safearray-get-element inters (+ j 1))
                                (vlax-safearray-get-element inters (+ j 2))
                          ))
                  (setq intersections (cons pt intersections))
                  (setq j (+ j 3))
                )
              )
            )
          )
        )
        (setq i (1+ i))
      )
    )
  )
  
  ;; Add vertices of original polyline to intersection points
  (setq vertices (get-poly-vertices polyent))
  (setq intersections (append vertices intersections))
  
  ;; Sort points along polyline and remove duplicates
  (setq intersections (sort-by-distance polyent intersections))
  
  ;; Create dimensions
  (if (> (length intersections) 1)
    (progn
      (setq i 0)
      (repeat (1- (length intersections))
        (setq pt1 (nth i intersections))
        (setq pt2 (nth (1+ i) intersections))
        (command "_dimaligned" pt1 pt2 "")
        (setq i (1+ i))
      )
      (princ (strcat "\nCreated " (itoa (1- (length intersections))) " dimensions."))
    )
    (princ "\nNot enough intersection points found.")
  )
  
  ;; Restore OSNAP setting
  (setvar "OSMODE" osnap)
  (princ)
)

;; Get polyline vertices
(defun get-poly-vertices (polyent / obj verts pts i)
  (setq obj (vlax-ename->vla-object polyent))
  (setq pts (list))
  
  ;; Handle different polyline types
  (cond
    ;; LWPolyline
    ((= (vla-get-objectname obj) "AcDbPolyline")
     (setq verts (vlax-variant-value (vla-get-coordinates obj)))
     (setq i 0)
     (while (< i (/ (vlax-safearray-get-u-bound verts 1) 2))
       (setq pts (cons (list 
                        (vlax-safearray-get-element verts (* i 2))
                        (vlax-safearray-get-element verts (1+ (* i 2)))
                        0.0)
                      pts))
       (setq i (1+ i))
     )
    )
    ;; 3D Polyline or old-style polyline
    ((or (= (vla-get-objectname obj) "AcDb3dPolyline")
         (= (vla-get-objectname obj) "AcDbPolyline"))
     (vlax-for vertex (vla-item (vla-get-blocks 
                                 (vla-get-document obj)) 
                              (vla-get-blockname obj))
       (if (= (vla-get-objectname vertex) "AcDbVertex")
         (setq pts (cons (vlax-variant-value 
                           (vla-get-position vertex)) pts))
       )
     )
    )
  )
  (reverse pts)
)

;; Sort points by distance along polyline
(defun sort-by-distance (polyent pts / obj poly-pts result i unique-pts)
  (setq obj (vlax-ename->vla-object polyent))
  (setq poly-pts (get-poly-vertices polyent))
  
  ;; Sort points
  (setq result (vl-sort pts
                 (function 
                   (lambda (p1 p2)
                     (< (distance-along-polyline poly-pts p1)
                        (distance-along-polyline poly-pts p2))
                   )
                 )
               ))
  
  ;; Remove duplicates
  (setq i 0)
  (setq unique-pts (list (car result)))
  (foreach pt (cdr result)
    (if (> (distance (car unique-pts) pt) 0.001)
      (setq unique-pts (cons pt unique-pts))
    )
  )
  (reverse unique-pts)
)

;; Calculate distance along polyline to a point
(defun distance-along-polyline (poly-pts pt / best-dist total-dist i best-seg best-param
                                              p1 p2 param proj dist seg-len)
  (setq best-dist 1e99)
  (setq best-seg 0)
  (setq best-param 0.0)
  
  ;; Find closest segment
  (setq i 0)
  (repeat (1- (length poly-pts))
    (setq p1 (nth i poly-pts))
    (setq p2 (nth (1+ i) poly-pts))
    
    ;; Get parameter and distance to segment
    (setq param (point-to-segment-param pt p1 p2))
    (setq proj (list
                 (+ (car p1) (* param (- (car p2) (car p1))))
                 (+ (cadr p1) (* param (- (cadr p2) (cadr p1))))
                 (+ (caddr p1) (* param (- (caddr p2) (caddr p1))))
               ))
    (setq dist (distance pt proj))
    
    ;; Keep track of closest segment
    (if (< dist best-dist)
      (progn
        (setq best-dist dist)
        (setq best-seg i)
        (setq best-param param)
      )
    )
    (setq i (1+ i))
  )
  
  ;; Calculate distance to point along polyline
  (setq total-dist 0.0)
  (setq i 0)
  (repeat best-seg
    (setq total-dist (+ total-dist (distance (nth i poly-pts) (nth (1+ i) poly-pts))))
    (setq i (1+ i))
  )
  
  ;; Add partial distance of current segment
  (setq seg-len (distance (nth best-seg poly-pts) (nth (1+ best-seg) poly-pts)))
  (setq total-dist (+ total-dist (* best-param seg-len)))
  
  total-dist
)

;; Calculate parameter of point projection on segment
(defun point-to-segment-param (pt p1 p2 / v1 v2 dot len-sq)
  (setq v1 (list (- (car p2) (car p1)) 
                (- (cadr p2) (cadr p1))
                (- (caddr p2) (caddr p1))))
  (setq v2 (list (- (car pt) (car p1))
                (- (cadr pt) (cadr p1))
                (- (caddr pt) (caddr p1))))
  
  (setq dot (+ (* (car v1) (car v2)) 
              (* (cadr v1) (cadr v2))
              (* (caddr v1) (caddr v2))))
  (setq len-sq (+ (* (car v1) (car v1))
                 (* (cadr v1) (cadr v1))
                 (* (caddr v1) (caddr v1))))
  
  (if (zerop len-sq)
    0.0
    (max 0.0 (min 1.0 (/ dot len-sq)))
  )
)

;; Load ActiveX support if not already loaded
(if (not (vl-bb-ref 'ACAD_ACTIVEX_ENABLED))
  (vl-load-com)
)

(princ "\nLoaded: PolyDimension. Type PolyDimension at the command line.")
(princ)