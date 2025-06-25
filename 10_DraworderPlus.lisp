(defun c:DraworderPlus (/ ss opt cmd)
  (setq cmd "DRAWORDER")
  
  ;; Prompt user to select objects to reorder
  (if (setq ss (ssget))
    (progn
      ;; Prompt for Front or Back option
      (initget "Front Back")
      (setq opt (getkword "\nSelect option [Front/Back] <Back>: "))
      
      ;; Default to Back if no option selected
      (if (= opt nil) (setq opt "Back"))
      
      ;; Execute the DRAWORDER command with the selected option
      (command cmd ss "" opt "")
      (princ (strcat "\nObjects moved to " opt "."))
    )
    (princ "\nNo objects selected.")
  )
  (princ)
)

;; Register the command with a short alias
(defun c:DOP () (c:DraworderPlus))

;; Add description for the command
(vl-load-com)
(if (= (vla-get-name (vla-get-activedocument (vlax-get-acad-object))) "Drawing")
    (vl-registry-write 
      "HKEY_CURRENT_USER\\Software\\Autodesk\\AutoCAD\\Command Descriptions\\DraworderPlus"
      "Simplified DRAWORDER with Front/Back options only"
    )
)

;; Print message when loaded
(princ "\nDraworderPlus loaded. Type DRAWORDERPLUS or DOP to use.")
(princ)