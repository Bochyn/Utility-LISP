(defun c:SelByBlockColor (/ selObj entData colorIndex rgbColor layerName layerColor filterList)
  ;; Prompt user to select a block
  (setq selObj (car (entsel "\nSelect a block to match color: ")))
  (if selObj
    (progn
      ;; Get entity data
      (setq entData (entget selObj))
      ;; Check if it's a block (type is "INSERT")
      (if (= (cdr (assoc 0 entData)) "INSERT")
        (progn
          ;; Check color
          (cond
            ;; Indexed color (62 group code)
            ((assoc 62 entData)
             (setq colorIndex (cdr (assoc 62 entData)))
             ;; If BYLAYER (-256), get layer's color
             (if (= colorIndex -256)
               (progn
                 (setq layerName (cdr (assoc 8 entData)))
                 (setq layerColor (cdr (assoc 62 (tblsearch "layer" layerName))))
                 (setq filterList (list (cons 0 "INSERT") (cons 62 layerColor))))
               (setq filterList (list (cons 0 "INSERT") (cons 62 colorIndex)))))
            ;; RGB color (420 group code)
            ((assoc 420 entData)
             (setq rgbColor (cdr (assoc 420 entData)))
             (setq filterList (list (cons 0 "INSERT") (cons 420 rgbColor))))
            ;; Invalid color or BYBLOCK
            (T
             (princ "\nThe selected block does not have a valid color property.")
             (exit)))
          ;; Select matching blocks
          (sssetfirst nil (ssget "X" filterList))
          (princ "\nAll blocks with the same color have been selected.")
        )
        ;; Not a block
        (princ "\nThe selected object is not a block.")
      )
    )
    ;; No object selected
    (princ "\nNo object selected.")
  )
  (princ) ; End the function
)
