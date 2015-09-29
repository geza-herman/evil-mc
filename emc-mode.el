;;; emc-mode.el --- Multiple cursors minor mode for evil

;; Author: Gabriel Adomnicai <gabesoft@gmail.com>
;; Version: 0.0.1
;; Keywords: evil editing cursors vim evil-multiple-cursors emc
;; Package-Requires ((emacs "24") (evil "1.2.3"))
;; Homepage: https://github.com/gabesoft/evil-multiple-cursors
;;
;; This file is not part of GNU Emacs.

;;; Commentary:

(require 'evil)

(require 'emc-common)
(require 'emc-vars)
(require 'emc-cursor-state)
(require 'emc-cursor-make)
(require 'emc-command-record)
(require 'emc-command-execute)
(require 'emc-region)

(eval-when-compile (require 'cl-lib))

;;; Code:

(defgroup evil-mc nil
  "Multiple cursors implementation for evil mode."
  :prefix "evil-mc-"
  :group 'evil)

(define-minor-mode evil-mc-mode
  "Minor mode for evil multiple cursors."
  :group 'evil-mc)

(defvar evil-multiple-cursors-mode-map
  (let ((map (make-sparse-keymap)))
    ;; TODO: find better keys
    ;; maybe try something like
    ;; - gcn     - next
    ;; - gcp/gcu - unod
    ;; - gcx     - skip
    ;; - gcr     - remove
    ;; - gch     - cursor here (would need to have a cursor create mode to avoid moving existing cursors)
    (evil-define-key 'visual map (kbd "C-n") 'emc-make-next-cursor)
    (evil-define-key 'normal map (kbd "C-n") 'emc-make-next-cursor)

    (evil-define-key 'visual map (kbd "C-t") 'emc-skip-next-cursor)
    (evil-define-key 'normal map (kbd "C-t") 'emc-skip-next-cursor)

    (evil-define-key 'visual map (kbd "C-p") 'emc-undo-prev-cursor)
    (evil-define-key 'normal map (kbd "C-p") 'emc-undo-prev-cursor)

    (evil-define-key 'visual map (kbd "C-P") 'emc-make-prev-cursor)
    (evil-define-key 'normal map (kbd "C-P") 'emc-make-prev-cursor)

    ;; this should be bound to ESC
    (evil-define-key 'normal map (kbd "C-,") 'emc-remove-all-cursors)
    map))

;; TODO: see evil-snipe for examples on defining custom variables
;; TODO: check evil-multiple-cursors-mode before doing anything in pre/post command hooks

;;;###autoload
(define-minor-mode evil-multiple-cursors-mode
  "evil-multiple-cursors minor mode."
  :global t
  :lighter " emc"
  :keymap evil-multiple-cursors-mode-map
  :group 'evil-multiple-cursors
  (if evil-multiple-cursors
      (turn-on-evil-multiple-cursors-mode t)
    (turn-off-evil-multiple-cursors-mode t)))

;;;###autoload
(defun turn-on-evil-multiple-cursors-mode (&optional internal)
  "Enable evil-multiple-cursors-mode in the current buffer."
  (unless internal (evil-multiple-cursors-mode 1))
  (when (fboundp 'advice-add)
    (advice-add 'evil-force-normal-state :before 'evil-multiple-cursors--pre-command))
  (add-hook 'evil-insert-state-entry-hook 'evil-multiple-cursors--disable-transient-map))

;;;###autoload
(defun turn-off-evil-multiple-cursors-mode (&optional internal)
  "Disable evil-multiple-cursors-mode in the current buffer."
  (when (fboundp 'advice-remove)
    (advice-remove 'evil-force-normal-state 'evil-multiple-cursors--pre-command))
  (remove-hook 'evil-insert-state-entry-hook 'evil-multiple-cursors--disable-transient-map)
  (unless internal (evil-multiple-cursors-mode -1))
  (evil-multiple-cursors-override-mode -1))


(provide 'emc-mode)

;;; emc-mode.el ends here