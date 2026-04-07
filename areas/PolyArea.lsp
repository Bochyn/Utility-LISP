;;; ============================================================================
;;; PolyArea.lsp
;;;
;;; Inserts a LIVE AutoCAD field displaying the area of a single closed
;;; polyline; the field updates automatically when the polyline changes.
;;;
;;; Command:    POLYAREA
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:Polyarea (/ ent obj objID fieldStr pt txtHeight)
  (prompt "\nSelect a polyline: ")
  (setq ent (car (entsel)))

  (if ent
    (progn
      ;; Verify the selected entity is a polyline.
      (if (or (= (cdr (assoc 0 (entget ent))) "LWPOLYLINE")
              (= (cdr (assoc 0 (entget ent))) "POLYLINE"))
        (progn
          (setq obj (vlax-ename->vla-object ent))

          ;; Verify the polyline is closed.
          (if (= (vlax-get-property obj 'Closed) :vlax-true)
            (progn
              ;; Ask for the text height, default to current TEXTSIZE.
              (setq txtHeight (getreal (strcat "\nText height <" (rtos (getvar "TEXTSIZE") 2 2) ">: ")))
              (if (not txtHeight) (setq txtHeight (getvar "TEXTSIZE")))

              ;; Fetch the AutoCAD ObjectID used inside the field expression.
              (setq objID (vla-get-objectid obj))

              ;; Build the AutoCAD field expression.
              ;; Format directives:
              ;;   %lu2         - linear units, decimal mode
              ;;   %ct8[0.0001] - conversion factor (mm^2 -> m^2)
              ;;   %pr2         - precision: 2 decimal places (0.00)
              ;;   %ps[]        - prefix/suffix (none)
              ;;   %th44        - thousands separator
              (setq fieldStr (strcat
                "%<\\AcObjProp Object(%<\\_ObjId "
                (itoa objID)
                ">%).Area \\f \"%lu2%ct8[0.0001]%pr2%ps[]%th44\">%"
              ))

              ;; Pick the insertion point for the MTEXT entity.
              (setq pt (getpoint "\nPick insertion point for the field: "))

              (if pt
                (progn
                  (command "_MTEXT" pt "_Height" txtHeight "_Width" 0 fieldStr "")
                  (prompt "\nArea field created.")
                  (prompt "\nFormat: conversion factor 0.0001, precision 0.00")
                )
              )
            )
            (prompt "\nThe selected polyline is not closed.")
          )
        )
        (prompt "\nThe selected object is not a polyline.")
      )
    )
    (prompt "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: POLYAREA. Type POLYAREA at the command line.")
(princ)
