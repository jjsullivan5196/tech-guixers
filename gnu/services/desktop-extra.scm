(define-module (gnu services desktop-extra)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services dbus)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services pam-mount)
  #:use-module (gnu system shadow)
  #:use-module (gnu system pam)
  #:use-module (gnu system file-systems)
  #:use-module (gnu packages freedesktop)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

(define polkit-wheel-nopass
  (file-union
   "polkit-wheel"
   `(("share/polkit-1/rules.d/01-wheel-nopass.rules"
      ,(plain-file
        "wheel-nopass.rules"
        "polkit.addRule(function(action, subject) {
    if(subject.isInGroup('wheel')) return polkit.Result.YES;
});
")))))

(define-public polkit-wheel-nopass-service
  (simple-service 'polkit-wheel-nopass polkit-service-type (list polkit-wheel-nopass)))

(define-public xdg-rundir-file-system
  (file-system
   (device "none")
   (mount-point "/run/user")
   (type "tmpfs")
   (check? #f)
   (flags '(no-suid no-dev no-exec))
   (options "mode=0755")
   (create-mount-point? #t)))

(define-public xdg-rundir-user-mount-rules
  `((debug (@ (enable "0")))
    (volume (@ (fstype "tmpfs")
               (mountpoint "/run/user/%(USERUID)")
               (options "rw,relatime,size=1635236k,nr_inodes=408809,mode=700,uid=%(USERUID),gid=%(USERGID)")))
    (mntoptions (@ (allow ,(string-join
                            '("nosuid" "nodev" "loop"
                              "encryption" "fsck" "nonempty"
                              "allow_root" "allow_other" "size"
                              "nr_inodes" "mode" "gid" "uid")
                            ","))))
    (mntoptions (@ (require "nosuid,nodev")))
    (logout (@ (wait "0")
               (hup "0")
               (term "no")
               (kill "no")))
    (mkmountpoint (@ (enable "1")
                     (remove "true")))))

(define-public xdg-rundir-user-mount-service
  (service pam-mount-service-type
           (pam-mount-configuration
            (rules xdg-rundir-user-mount-rules))))

(define-public seatd-service
  (simple-service 'seatd-service shepherd-root-service-type
                  (list (shepherd-service
                         (provision '(seatd elogind))
                         (start #~(make-forkexec-constructor
                                   (list #$(file-append seatd "/bin/seatd") "-g" "users")))
                         (stop #~(make-kill-destructor))))))
