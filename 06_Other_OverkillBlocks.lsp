(defun c:OVERKILLBLOCKS (/ selSet blk1 blk2 pos1 pos2 name1 name2 i j n)
  (setq selSet (ssget "_X" '((0 . "INSERT")))) ; Get all block references
  (if selSet
    (progn
      (setq n (sslength selSet)) ; Number of selected blocks
      (setq i 0)
      (while (< i n) ; Outer loop through all blocks
        (setq blk1 (ssname selSet i))
        (setq pos1 (cdr (assoc 10 (entget blk1)))) ; Insertion point of blk1
        (setq name1 (cdr (assoc 2 (entget blk1)))) ; Name of blk1
        (setq j (1+ i))
        (while (< j n) ; Inner loop to compare blk1 with the rest
          (setq blk2 (ssname selSet j))
          (setq pos2 (cdr (assoc 10 (entget blk2)))) ; Insertion point of blk2
          (setq name2 (cdr (assoc 2 (entget blk2)))) ; Name of blk2
          (if (and (equal pos1 pos2 0.001) ; Check if positions match
                   (equal name1 name2))   ; Check if names match
            (progn
              (entdel blk2) ; Delete duplicate block
              (setq selSet (ssdel blk2 selSet)) ; Remove from selection set
              (setq n (1- n)) ; Adjust total block count
              (setq j (1- j)) ; Stay at the current index
            )
          )
          (setq j (1+ j)) ; Move to the next block
        )
        (setq i (1+ i))
      )
      (princ "\nDuplicate blocks removed!")
    )
    (princ "\nNo blocks found.")
  )
  (princ)
)
