;;; early-local.example.el --- Machine-local early settings -*- lexical-binding: t; -*-

;; Copy this file to ~/.emacs.d/early-local.el on each machine and set the
;; HTTP proxy port used by that machine.  This file is loaded before package.el
;; refreshes archives or use-package installs missing packages.

(setq maeiee-proxy-port 7890)

(let ((proxy (format "127.0.0.1:%d" maeiee-proxy-port)))
  ;; Used by Emacs URL clients, including package.el.
  (setq url-proxy-services
        `(("http"     . ,proxy)
          ("https"    . ,proxy)
          ("no_proxy" . "^\\(localhost\\|127\\.0\\.0\\.1\\)$")))

  ;; Also expose the proxy to subprocesses started by Emacs.
  (setenv "http_proxy" (concat "http://" proxy))
  (setenv "https_proxy" (concat "http://" proxy))
  (setenv "no_proxy" "localhost,127.0.0.1"))

;;; early-local.example.el ends here
