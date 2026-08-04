;; [[file:../modules/40-vertico.org::*配置][配置:1]]
(use-package vertico
  :demand t
  :init
  (vertico-mode 1)
  :custom
  (vertico-count 15)
  (vertico-cycle t))
;; 配置:1 ends here
