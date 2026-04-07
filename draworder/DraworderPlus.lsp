;;;; DraworderPlus - Enhanced DRAWORDER command
;;;; Usage: Select objects first, then type DRAWORDERPLUS or DOP
;;;; Options: F = Above everything, R = Below everything, G = Front, T = Back

(defun c:DraworderPlus (/ ss opt)
  ;; Use pre-selection if available, otherwise prompt for selection
  (if (setq ss (ssget "_I"))
    (progn
      ;; Pre-selection exists, continue with options
      (initget "F R G T")
      (setq opt (getkword "\nF=Above everything, R=Below everything, G=Front, T=Back: "))
      
      ;; Default to R if no option selected
      (if (= opt nil) (setq opt "R"))
      
      ;; Execute the appropriate DRAWORDER command based on selection
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
    ;; No pre-selection, ask user to select objects first
    (princ "\nPlease select objects first, then run DRAWORDERPLUS.")
  )
  (princ)
)

;; Register the command with a short alias
(defun c:DOP () (c:DraworderPlus))

;; Print message when loaded
(princ "\nDraworderPlus loaded. Select objects, then use DRAWORDERPLUS or DOP command.")
(princ)