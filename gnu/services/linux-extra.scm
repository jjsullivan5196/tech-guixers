(define-module (gnu services linux-extra)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services linux)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 match))

;; Get the module name of a modprobe spec.
(define loadable-name
  (match-lambda
    ((? package? pkg)
     (substring (package-name pkg)
                0
                (string-index (package-name pkg) #\-)))
    ((? string? name)
     name)
    (_ #f)))

;; Turn the modprobe spec into a modprobe conf file.
(define module-options->gexp
  (match-lambda
    (((? loadable-name module) opts)
     (let* [(name (loadable-name module))
            (fname (string-append name ".conf"))]
       `(,(string-append "modprobe.d/" fname)
         ,(plain-file
           fname
           (string-join (cons* "options" name
                               (map (lambda (o)
                                      (string-append
                                       (list-ref o 0) "=" (list-ref o 1)))
                                    opts))
                        " ")))))
    (_ #f)))

(define-public modprobe-service-type
  (service-type
   (name 'modprobe)
   (extensions
    (list (service-extension linux-loadable-module-service-type
                             (compose (cut filter package? <>)
                                      (cut map car <>)))
          (service-extension kernel-module-loader-service-type
                             (compose (cut filter identity <>)
                                      (cut map (compose loadable-name car) <>)))
          (service-extension etc-service-type
                             (compose (cut filter identity <>)
                                      (cut map module-options->gexp <>)))))
   (default-value '())
   (description "Adds modules given in modprobe specs to the kernel profile and loads them at
boot.")))

#! ;; testing

(use-modules (gnu packages linux))

(map loadable-name
     `((,v4l2loopback-linux-module (("exclusive_caps" "1")
                                    ("card_label" "VirtualVideoDevice")))))

(map module-options->gexp
     `((,v4l2loopback-linux-module (("exclusive_caps" "1")
                                    ("card_label" "VirtualVideoDevice")))))

!#
