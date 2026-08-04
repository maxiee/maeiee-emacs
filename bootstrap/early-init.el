;;; early-init.el --- Early startup for Maeiee Emacs -*- lexical-binding: t; -*-

;; Emacs normally activates installed packages before reading init.el.
;; We turn that off so package initialization happens explicitly in 00-package.org.
(setq package-enable-at-startup nil)

;; Avoid a visual resize during startup.
(setq frame-inhibit-implied-resize t)

;; Keep the first frame quiet and uncluttered.
(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Temporarily reduce garbage collections while loading the configuration.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook
 'emacs-startup-hook
 (lambda ()
   (setq gc-cons-threshold (* 64 1024 1024)
         gc-cons-percentage 0.1)))

(provide 'early-init)
;;; early-init.el ends here
