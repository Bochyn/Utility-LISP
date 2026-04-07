;;; ============================================================================
;;; SelectBlocksInView.lsp
;;;
;;; Iterates over every entity in the drawing database and builds a selection
;;; set containing only block references (INSERT entities).
;;;
;;; Command:    SelectBlocksInView
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelectBlocksInView (/ ssAll ssBlocks i ent)
  (setq ssAll    (ssget "_X"))                                 ; all entities in DB
  (setq ssBlocks (ssadd))                                      ; empty selection set
  (if ssAll
    (progn
      (setq i 0)
      (while (< i (sslength ssAll))
        (setq ent (ssname ssAll i))
        ;; DXF 0 = entity type. "INSERT" identifies a block reference.
        (if (eq (cdr (assoc 0 (entget ent))) "INSERT")
          (ssadd ent ssBlocks)
        )
        (setq i (1+ i))
      )
    )
  )
  (if (> (sslength ssBlocks) 0)
    (progn
      (sssetfirst nil ssBlocks)
      (princ (strcat "\n" (itoa (sslength ssBlocks)) " blocks selected."))
    )
    (princ "\nNo blocks found in view.")
  )
  (princ)
)

(princ "\nLoaded: SelectBlocksInView. Type SelectBlocksInView at the command line.")
(princ)
