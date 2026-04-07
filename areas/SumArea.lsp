;;; ============================================================================
;;; SumArea.lsp
;;;
;;; Sums the areas of multiple closed polylines and inserts a LIVE AutoCAD
;;; field that updates automatically when the polylines change.
;;;
;;; Command:    SUMAREA
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SUMAREA (/ ss cnt i ent obj objID fieldStr pt)
  (prompt "\nSelect closed polylines to sum: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if ss
    (progn
      (setq cnt (sslength ss))

      ;; Build the AutoCAD field expression.
      ;; Format directives used at the end of the expression:
      ;;   %lu2        - linear units, decimal mode
      ;;   %ct8[0.0001] - conversion factor (mm^2 -> m^2)
      ;;   %pr2        - precision: 2 decimal places (0.00)
      ;;   %ps[]       - prefix/suffix (none)
      ;;   %th44       - thousands separator
      (setq fieldStr "%<\\AcExpr (")
      (setq i 0)

      (repeat cnt
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))

        (if (= (vlax-get-property obj 'Closed) :vlax-true)
          (progn
            (setq objID (vla-get-objectid obj))

            (if (> i 0)
              (setq fieldStr (strcat fieldStr " + "))
            )

            ;; Append one ObjId(...).Area term to the expression.
            (setq fieldStr (strcat fieldStr
              "%<\\AcObjProp Object(%<\\_ObjId "
              (itoa objID)
              ">%).Area>%"
            ))
          )
          (prompt (strcat "\nPolyline " (itoa (1+ i)) " skipped (not closed)."))
        )
        (setq i (1+ i))
      )

      ;; Close the expression and append field formatting directives.
      (setq fieldStr (strcat fieldStr ") \\f \"%lu2%ct8[0.0001]%pr2%ps[]%th44\">%"))

      (setq pt (getpoint "\nPick insertion point for the field: "))

      (if pt
        (progn
          (command "_MTEXT" pt "_Height" (getvar "TEXTSIZE") "_Width" 0 fieldStr "")
          (prompt (strcat "\nCreated sum field for " (itoa cnt) " polylines."))
          (prompt "\nFormat: conversion factor 0.0001, precision 0.00")
        )
      )
    )
    (prompt "\nNo polylines selected.")
  )
  (princ)
)

(princ "\nLoaded: SUMAREA. Type SUMAREA at the command line.")
(princ)
