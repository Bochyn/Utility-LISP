;;; ============================================================================
;;; OverkillBlocks.lsp
;;;
;;; Removes duplicate block references that share the same name and
;;; insertion point (an Overkill-style cleanup limited to INSERT entities).
;;;
;;; Command:    OVERKILLBLOCKS
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:OVERKILLBLOCKS (/ selSet blk1 blk2 pos1 pos2 name1 name2 i j n)
  (setq selSet (ssget "_X" '((0 . "INSERT")))) ; get all block references
  (if selSet
    (progn
      (setq n (sslength selSet))              ; number of selected blocks
      (setq i 0)
      (while (< i n)                          ; outer loop through all blocks
        (setq blk1 (ssname selSet i))
        (setq pos1 (cdr (assoc 10 (entget blk1)))) ; insertion point of blk1
        (setq name1 (cdr (assoc 2 (entget blk1)))) ; name of blk1
        (setq j (1+ i))
        (while (< j n)                        ; inner loop compares blk1 with the rest
          (setq blk2 (ssname selSet j))
          (setq pos2 (cdr (assoc 10 (entget blk2)))) ; insertion point of blk2
          (setq name2 (cdr (assoc 2 (entget blk2)))) ; name of blk2
          (if (and (equal pos1 pos2 0.001)    ; positions match within tolerance
                   (equal name1 name2))       ; and names match
            (progn
              (entdel blk2)                   ; delete the duplicate
              (setq selSet (ssdel blk2 selSet)) ; remove it from the selection set
              (setq n (1- n))                 ; adjust the count
              (setq j (1- j))                 ; stay at the current index
            )
          )
          (setq j (1+ j))                     ; advance inner index
        )
        (setq i (1+ i))
      )
      (princ "\nDuplicate blocks removed.")
    )
    (princ "\nNo blocks found.")
  )
  (princ)
)

(princ "\nLoaded: OVERKILLBLOCKS. Type OVERKILLBLOCKS at the command line.")
(princ)
