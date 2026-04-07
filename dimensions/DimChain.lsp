;;; ============================================================================
;;; DimChain.lsp
;;;
;;; Creates a chain of aligned dimensions and optionally wraps them into a
;;; stable Block or Group.
;;;
;;; Command:    DimChain
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:DimChain (/ *error* lastEnt ent ss choice blockName blockIndex insPt)

  ;; Error handler
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (setvar 'CMDECHO 1)
    (princ)
  )

  (setvar 'CMDECHO 0)

  ;; 1. Remember the last entity before we start
  (setq lastEnt (entlast))

  ;; 2. Run the first aligned dimension
  (princ "\nPlace the first aligned dimension:")
  (command "_.DIMALIGNED")
  (while (> (getvar "CMDACTIVE") 0) (command pause))

  ;; 3. Check whether a dimension was actually created
  (if (not (equal lastEnt (entlast)))
    (progn
      (princ "\nContinue dimensioning (Enter or ESC to finish):")

      ;; Dimcontinue from the last entity
      (command "_.DIMCONTINUE" (entlast))
      (while (> (getvar "CMDACTIVE") 0) (command pause))

      ;; 4. Collect the newly created dimensions
      (setq ss (ssadd))
      (if lastEnt
        (setq ent (entnext lastEnt))
        (setq ent (entnext))
      )

      (while ent
        (if (= (cdr (assoc 0 (entget ent))) "DIMENSION")
          (ssadd ent ss)
        )
        (setq ent (entnext ent))
      )

      ;; 5. Decide: Block / Group / Skip
      (if (> (sslength ss) 0)
        (progn
          ;; --- FIX FOR THE "RUNAWAY INTO SPACE" BUG ---
          ;; Associative dimensions drift away from their defpoints when the
          ;; host geometry is converted into a block. Disassociate them first
          ;; so the block stays anchored where it was created.
          (command "_.DIMDISASSOCIATE" ss "")
          ;; --------------------------------------------

          (initget "1 2 3")
          (setq choice (getkword "\nChoose action: [1=Block, 2=Group, 3=Skip] <1>: "))
          (if (not choice) (setq choice "1"))

          (cond
            ;; --- BLOCK ---
            ((equal choice "1")
             (setq blockIndex 1 blockName "DimBlock1")
             (while (tblsearch "BLOCK" blockName)
               (setq blockIndex (1+ blockIndex))
               (setq blockName (strcat "DimBlock" (itoa blockIndex)))
             )

             ;; DXF 13 is the geometry definition point (not text position)
             (setq insPt (cdr (assoc 13 (entget (ssname ss 0)))))

             (command "._-BLOCK" blockName insPt ss "")
             (command "._-INSERT" blockName insPt 1 1 0)
             (princ (strcat "\nCreated stable block: " blockName))
            )

            ;; --- GROUP ---
            ((equal choice "2")
             (command "._GROUP" "_C" "*" "" ss "")
             (princ "\nGroup created.")
            )

            ;; --- SKIP ---
            ((equal choice "3")
             (princ "\nDimensions left as-is.")
            )
          )
        )
        (princ "\nNo new dimensions detected.")
      )
    )
    (princ "\nCancelled.")
  )
  (setvar 'CMDECHO 1)
  (princ)
)

(princ "\nLoaded: DimChain. Type DimChain at the command line.")
(princ)
