;;; packages.el --- typescript Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Chris Bowdon <c.bowdon@bath.edu>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq ts-packages
      '(
        add-node-modules-path
        company
        eldoc
        flycheck
        smartparens
        tide
        typescript-mode
        web-mode
        yasnippet
        ))

(defun ts/post-init-add-node-modules-path ()
  (spacemacs/add-to-hooks #'add-node-modules-path '(typescript-mode-hook
                                             typescript-tsx-mode-hook)))

(defun ts/post-init-company ()
  (spacemacs/add-to-hooks #'spacemacs//ts-setup-company
                   '(typescript-mode-local-vars-hook
                   typescript-tsx-mode-local-vars-hook)))

(defun ts/post-init-eldoc ()
  (spacemacs/add-to-hooks #'spacemacs//ts-setup-eldoc
                   '(typescript-mode-local-vars-hook
                     typescript-tsx-mode-local-vars-hook) t))

(defun ts/post-init-flycheck ()
  (spacemacs/enable-flycheck 'typescript-mode)
  (spacemacs/enable-flycheck 'typescript-tsx-mode)
  (with-eval-after-load 'tide
    (with-eval-after-load 'flycheck
      (flycheck-add-mode 'typescript-tide 'typescript-tsx-mode)
      (flycheck-add-mode 'typescript-tslint 'typescript-tsx-mode))))

(defun ts/post-init-smartparens ()
  (if dotspacemacs-smartparens-strict-mode
      (spacemacs/add-to-hooks #'smartparens-strict-mode '(typescript-mode-hook
                                                   typescript-tsx-mode-hook))
    (spacemacs/add-to-hooks #'smartparens-mode '(typescript-mode-hook
                                          typescript-tsx-mode-hook))))

(defun ts/init-tide ()
  (use-package tide
    :defer t
    :commands (ts/jump-to-type-def)
    :config
    (progn
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mE" "errors")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mE" "errors")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mh" "help")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mh" "help")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mn" "name")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mn" "name")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mr" "refactor")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mr" "refactor")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "mS" "server")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "mS" "server")
      (spacemacs/declare-prefix-for-mode 'typescript-mode "ms" "send")
      (spacemacs/declare-prefix-for-mode 'typescript-tsx-mode "ms" "send")

      (setq keybindingList '("Ee" tide-fix
                             "Ed" tide-add-tslint-disable-next-line
                             "gb" tide-jump-back
                             "gg" tide-jump-to-definition
                             "gt" spacemacs/ts-jump-to-type-def
                             "gu" tide-references
                             "hh" tide-documentation-at-point
                             "ri" tide-organize-imports
                             "rr" tide-rename-symbol
                             "rf" tide-rename-file
                             "sr" tide-restart-server)
            typescriptList (cons 'typescript-mode keybindingList)
            typescriptTsxList (cons 'typescript-tsx-mode
                                    (cons "gg" (cons 'tide-jump-to-definition
                                                     keybindingList ))))
      (apply 'spacemacs/set-leader-keys-for-major-mode typescriptList)
      (apply 'spacemacs/set-leader-keys-for-major-mode typescriptTsxList)))

  (add-to-list 'spacemacs-jump-handlers-typescript-tsx-mode
               '(tide-jump-to-definition :async t))
  (add-to-list 'spacemacs-jump-handlers-typescript-mode
               '(tide-jump-to-definition :async t)))

(defun ts/post-init-web-mode ()
  (define-derived-mode typescript-tsx-mode web-mode "TypeScript-tsx")
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-tsx-mode)))

(defun ts/post-init-yasnippet ()
  (spacemacs/add-to-hooks #'spacemacs/ts-yasnippet-setup '(typescript-mode-hook
                                                     typescript-tsx-mode-hook)))

(defun ts/init-typescript-mode ()
  (use-package typescript-mode
    :defer t
    :init
    (progn
      ;; setup typescript backend
      (spacemacs/add-to-hooks #'spacemacs//ts-setup-backend
                       '(typescript-mode-local-vars-hook
                         typescript-tsx-mode-local-vars-hook))
      ;; safe values for backend to be used in directory file variables
      (dolist (value '(lsp tide))
        (add-to-list 'safe-local-variable-values
                     (cons 'ts-backend value))))
    :config
    (progn
      (when ts-fmt-on-save
        (spacemacs/add-to-hooks 'spacemacs/ts-fmt-before-save-hook
                         '(typescript-mode-hook typescript-tsx-mode-hook)))
      (spacemacs/set-leader-keys-for-major-mode 'typescript-mode
        "=="  'spacemacs/ts-format
        "sp" 'spacemacs/ts-open-region-in-playground)
      (spacemacs/set-leader-keys-for-major-mode 'typescript-tsx-mode
        "=="  'spacemacs/ts-format
        "sp" 'spacemacs/ts-open-region-in-playground))))
