(define-module (gnu packages lio)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages glib)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

(define-public python-configshell-fb
  (package
    (name "python-configshell-fb")
    (version "1.1.29")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "configshell-fb" version))
       (sha256
        (base32 "0n3i22mx08pzq5lh5g299lj46f5cq9mdndfk4571225qby9sm6g1"))))
    (build-system python-build-system)
    (propagated-inputs (list python-pyparsing-2.4.7 python-six python-urwid))
    (home-page "http://github.com/open-iscsi/configshell-fb")
    (synopsis "A framework to implement simple but nice CLIs.")
    (description
     "This package provides a framework to implement simple but nice CLIs.")
    (license license:asl2.0)))

(define-public python-rtslib-fb
  (package
    (name "python-rtslib-fb")
    (version "2.1.74")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "rtslib-fb" version))
       (sha256
        (base32 "0p4j18mz684qdr745qffk8g2ynwnh1cg7r6xkvr3a3aynlqbq5bg"))))
    (build-system python-build-system)
    (propagated-inputs (list python-pyudev python-six))
    (home-page "http://github.com/open-iscsi/rtslib-fb")
    (synopsis "API for Linux kernel SCSI target (aka LIO)")
    (description "API for Linux kernel SCSI target (aka LIO)")
    (license license:asl2.0)))

(define-public python-targetcli-fb
  (package
    (name "python-targetcli-fb")
    (version "2.1.51.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "targetcli-fb" version))
       (sha256
        (base32 "1s5jdkw0117s7m14pkp6vzwjq2nna0wkrgrgxnk3fh728ypcsc7i"))))
    (build-system python-build-system)
    (arguments `(#:phases
                 (modify-phases %standard-phases
                   (add-after 'unpack 'patch-prefix
                     (lambda _
                       (substitute* "setup.py"
                         (("/lib/systemd/system")
                          "lib/systemd/system")))))))
    (propagated-inputs (list python-pygobject python-configshell-fb python-rtslib-fb))
    (home-page "http://github.com/open-iscsi/targetcli-fb")
    (synopsis "An administration shell for RTS storage targets.")
    (description "An administration shell for RTS storage targets.")
    (license license:asl2.0)))
