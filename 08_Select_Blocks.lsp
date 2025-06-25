(defun c:SelectBlocksInView ()
  (setq ssAll (ssget "_X"))  ;; Get all visible objects

  (setq ssBlocks (ssadd))  ;; Create an empty selection set for blocks
  (if ssAll
    (progn
      (setq i 0)
      (while (< i (sslength ssAll))
        (setq ent (ssname ssAll i))
        (if (eq (cdr (assoc 0 (entget ent))) "INSERT")  ;; Check if it's a block
          (ssadd ent ssBlocks)
        )
        (setq i (1+ i))
      )
    )
  )

  ;; Select the blocks if any were found
  (if (> (sslength ssBlocks) 0)
    (progn
      (sssetfirst nil ssBlocks)  ;; Highlight selected blocks
      (princ (strcat "\n" (itoa (sslength ssBlocks)) " blocks selected."))
    )
    (princ "\nNo blocks found in view.")
  )

  (princ)  ;; Exit cleanly
)
