;;; ============================================================================
;;; DraworderPlus.lsp
;;;
;;; Enhanced DRAWORDER wrapper: select objects first, then choose whether
;;; they should go Above everything, Below everything, to the Front, or
;;; to the Back.
;;;
;;; Command:    DRAWORDERPLUS
;;; Alias:      DOP
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:DraworderPlus (/ ss opt)
  ;; Use the current pick-first selection, otherwise bail out.
  (if (setq ss (ssget "_I"))
    (progn
      ;; A selection exists - ask which placement to apply.
      (initget "F R G T")
      (setq opt (getkword "\nF=Above everything, R=Below everything, G=Front, T=Back: "))

      ;; Default to R (below everything) when the user just presses Enter.
      (if (= opt nil) (setq opt "R"))

      ;; Dispatch to the underlying DRAWORDER command.
      (cond
        ((= opt "F")
         (command "_DRAWORDER" ss "" "ABOVE" "_All" "")
         (princ "\nObjects moved above everything.")
        )
        ((= opt "R")
         (command "_DRAWORDER" ss "" "BELOW" "_All" "")
         (princ "\nObjects moved below everything.")
        )
        ((= opt "G")
         (command "_DRAWORDER" ss "" "FRONT" "")
         (princ "\nObjects moved to front.")
        )
        ((= opt "T")
         (command "_DRAWORDER" ss "" "BACK" "")
         (princ "\nObjects moved to back.")
        )
      )
    )
    ;; No pre-selection: ask the user to pick objects first.
    (princ "\nPlease select objects first, then run DRAWORDERPLUS.")
  )
  (princ)
)

;; Short alias: DOP -> DRAWORDERPLUS.
(defun c:DOP () (c:DraworderPlus))

(princ "\nLoaded: DRAWORDERPLUS. Type DRAWORDERPLUS at the command line.")
(princ)
