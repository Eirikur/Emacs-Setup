;;; init.el --- Python-focused init -*- lexical-binding: t; -*-

;;; Theme (waher is in elpa)
(package-initialize)
(load-theme 'waher :no-confirm)


;;; UI basics
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))


;;; Tree-sitter
(require 'treesit)
(setq treesit-font-lock-level 4)
(add-to-list 'treesit-extra-load-path
             (expand-file-name "tree-sitter" user-emacs-directory))
;; Pin to v0.20.4 — compatible with libtree-sitter 0.20.8 (ABI 14)
(add-to-list 'treesit-language-source-alist
             '(python "https://github.com/tree-sitter/tree-sitter-python" "v0.20.4"))
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))

;;; project.el: recognise uv/pyproject roots without needing .git
(use-package project
  :custom
  (project-vc-extra-root-markers '("pyproject.toml" ".project")))

;;; Venv detection
(defun my/uv-venv ()
  "Return the .venv path if it exists under the current project root."
  (when-let* ((proj (project-current))
              (root (project-root proj))
              (venv (expand-file-name ".venv" root))
              (_ (file-directory-p venv)))
    venv))

;;; eglot + basedpyright
(defun my/basedpyright-workspace-config (_server)
  "Point basedpyright at the project's uv .venv."
  (when-let* ((venv (my/uv-venv))
              (root (file-name-directory (directory-file-name venv))))
    `(:basedpyright (:venvPath ,root :venv ".venv"))))

(use-package eglot
  :custom
  (eglot-autoshutdown t)
  (eglot-report-progress nil)
  :config
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("basedpyright-langserver" "--stdio")))
  (setq-default eglot-workspace-configuration #'my/basedpyright-workspace-config)
  :hook
  (python-ts-mode . eglot-ensure))

;;; Python shell: point at the venv interpreter when in a uv project
(defun my/python-ts-mode-hook ()
  (when-let ((venv (my/uv-venv)))
    (setq-local python-shell-virtualenv-root venv)))

(add-hook 'python-ts-mode-hook #'my/python-ts-mode-hook)
