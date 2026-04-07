;;; ============================================================================
;;; SelByTextHeight.lsp
;;;
;;; Selects all text-like objects (TEXT, MTEXT, ATTDEF, ATTRIB) in the drawing
;;; whose height matches that of a user-picked reference text entity.
;;;
;;; Command:    SelByTextHeight
;;; Alias:      STH
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByTextHeight (/ ss ent entData txtHeight newSS i)
  (setvar "CMDECHO" 0)

  (princ "\nSelect reference text: ")
  (setq ent (car (entsel)))

  (if (null ent)
    (progn
      (princ "\nNo object selected.")
      (princ)
      (exit)
    )
  )

  (setq entData (entget ent))

  ;; DXF 0 = entity type. Accept only text-bearing entities.
  (if (and (/= (cdr (assoc 0 entData)) "TEXT")
           (/= (cdr (assoc 0 entData)) "MTEXT")
           (/= (cdr (assoc 0 entData)) "ATTDEF")
           (/= (cdr (assoc 0 entData)) "ATTRIB"))
    (progn
      (princ "\nSelected object is not a text entity.")
      (princ)
      (exit)
    )
  )

  ;; DXF 40 carries the nominal height for both TEXT and MTEXT families.
  (setq txtHeight (cdr (assoc 40 entData)))

  (princ (strcat "\nSearching for text objects with height: " (rtos txtHeight 2 2)))

  (setq ss (ssget "X" '((0 . "TEXT,MTEXT,ATTDEF,ATTRIB"))))

  (if (null ss)
    (progn
      (princ "\nNo text objects found in the drawing.")
      (princ)
      (exit)
    )
  )

  (setq newSS (ssadd))

  ;; Walk the candidate set and collect entities matching the target height
  ;; within a small epsilon to tolerate floating-point rounding.
  (setq i 0)
  (repeat (sslength ss)
    (setq ent     (ssname ss i))
    (setq entData (entget ent))
    (if (= (cdr (assoc 0 entData)) "MTEXT")
      (if (equal (cdr (assoc 40 entData)) txtHeight 0.0001)
        (setq newSS (ssadd ent newSS))
      )
      (if (equal (cdr (assoc 40 entData)) txtHeight 0.0001)
        (setq newSS (ssadd ent newSS))
      )
    )
    (setq i (1+ i))
  )

  (if (> (sslength newSS) 0)
    (progn
      (sssetfirst nil newSS)
      (princ (strcat "\nSelected " (itoa (sslength newSS)) " text objects."))
    )
    (princ "\nNo text objects with the specified height were found.")
  )

  (princ)
)

;; Short alias for faster command-line use.
(defun c:STH () (c:SelByTextHeight))

(princ "\nLoaded: SelByTextHeight. Type SelByTextHeight or STH at the command line.")
(princ)
