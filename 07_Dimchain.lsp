(defun c:DimChain ()
  ;; Get all existing dimensions before running the command
  (setq oldDims (ssget "X" '((0 . "DIMENSION"))))

  ;; Start the first aligned dimension
  (command "DIMALIGNED")
  (while (> (getvar 'CMDACTIVE) 0) (command PAUSE))  ;; Wait for user input

  ;; Start DIMCONTINUE
  (command "DIMCONTINUE")
  (while (> (getvar 'CMDACTIVE) 0) (command PAUSE))  ;; Wait for user to continue placing dimensions
  (command "")  ;; FORCE EXIT DIMCONTINUE

  ;; Select all dimensions AFTER finishing DIMCONTINUE
  (setq allDims (ssget "X" '((0 . "DIMENSION"))))

  ;; Create a selection set for new dimensions only
  (setq ss (ssadd))
  (if allDims
    (progn
      (setq i 0)
      (while (< i (sslength allDims))
        (setq ent (ssname allDims i))
        (if (or (not oldDims) (not (ssmemb ent oldDims)))  ;; Add only NEW dimensions
          (ssadd ent ss)
        )
        (setq i (1+ i))
      )
    )
  )

  ;; Ensure dimensions were created
  (if (> (sslength ss) 0)
    (progn
      ;; Prompt user to choose Block (1), Group (2), or Skip (3)
      (initget "1 2 3")
      (setq choice (getkword "\nChoose: [1=Block, 2=Group, 3=Skip]: "))

      (cond
        ;; Create a unique block name
        ((equal choice "1")
         (setq blockIndex 1 blockName "DimBlock1")
         ;; Find the next available unique block name
         (while (tblsearch "BLOCK" blockName)
           (setq blockIndex (1+ blockIndex))
           (setq blockName (strcat "DimBlock" (itoa blockIndex)))
         )
         (setq insPt (cdr (assoc 10 (entget (ssname ss 0)))))  ;; Get insertion point
         (command "._-BLOCK" blockName insPt ss "")
         (command "._-INSERT" blockName insPt 1 1 0)
        )

        ;; Create a group
        ((equal choice "2")
         (command "._GROUP" "_C" "*" "" ss "")
        )

        ;; Skip (Do Nothing)
        ((equal choice "3")
         (princ "\nLeaving dimensions as they are.")
        )
      )
    )
    (princ "\nNo new dimensions created.")  ;; Exit if no new dimensions found
  )

  (princ)  ;; Exit cleanly
)
