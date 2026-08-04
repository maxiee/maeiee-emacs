;; [[file:../modules/41-orderless.org::*配置][配置:1]]
(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))
;; 配置:1 ends here
