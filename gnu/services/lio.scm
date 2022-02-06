(define-module (gnu services lio)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services shepherd)
  #:use-module (gnu packages lio)
  #:use-module (guix packages)
  #:use-module (guix records)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:export (<lio-target-configuration>
            lio-target-configuration
            make-lio-target-configuration
            lio-target-configuration?))

(define-record-type* <lio-target-configuration>
  lio-target-configuration make-lio-target-configuration
  lio-target-configuration?
  (rtslib lio-target-configuration-rtslib ;file-like
          (default python-rtslib-fb)))

(define (lio-target-service-activation _config)
  #~(begin
      (use-modules (guix build utils))
      (mkdir-p "/etc/target")))

(define (lio-target-shepherd-service config)
  (match-record config <lio-target-configuration>
    (rtslib)
    (list (shepherd-service
           (requirement '(networking))
           (provision '(lio-target))
           (start #~(make-system-constructor
                     #$(file-append rtslib "/bin/targetctl") " restore"))
           (stop #~(make-system-destructor
                    #$(file-append rtslib "/bin/targetctl") " clear"))))))

(define-public lio-target-service-type
  (service-type
   (name 'lio-target)
   (default-value (lio-target-configuration))
   (extensions
    (list (service-extension shepherd-root-service-type
                             lio-target-shepherd-service)
          (service-extension activation-service-type
                             lio-target-service-activation)))))
