(define (init)
  (initSwarmBatch "print-table" "0.0" "bug-swarm@swarm.org" #t))

(define (print-record-using-probemap probeMap :: <swarm.objectbase.ProbeMap> obj)
  (let* ((index :: <swarm.collections.Index>
                (invoke probeMap 'begin *scratchZone*)))
    (let loop ((varprobe :: <swarm.objectbase.VarProbe> (invoke index 'next)))
      (if (eq? (invoke index 'getLoc) *Member*)
          (let ((name (invoke varprobe 'getProbedVariable)))
            (if (not (or (string=? name "isa")
                         (string=? name "zbits")))
                (let ((string :: <swarm.collections.String> 
                              (invoke varprobe 'probeAsString obj)))
                  (display " ")
                  (display (invoke string 'getC))
                  (let ((drop-string :: <swarm.defobj.Drop> string))
                    (invoke drop-string 'drop))))
            (loop (invoke index 'next)))))))

(define (print-record-for-key archiver :: <swarm.defobj.Archiver> key)
  (let ((string :: <java.lang.String> key))
    (let* ((list :: <swarm.collections.Collection>
                 (invoke archiver 'getObject string))
           (index :: <swarm.collections.Index>
                  (invoke list 'begin *scratchZone*))
           (probeLibrary :: <swarm.objectbase.ProbeLibrary> *probeLibrary*)
           (start-obj (invoke index 'next))
           (class (invoke start-obj 'getClass))
           (probeMap :: <swarm.objectbase.ProbeMap>
                     (invoke probeLibrary 'getCompleteVarMapFor class)))
      (let loop ((obj start-obj))
        (if (eq? (invoke index 'getLoc) *Member*)
            (begin
              (print-record-using-probemap probeMap obj)
              (newline)
              (loop (invoke index 'next))))))))

(define (print archiver-procedure)
  (let ((args (vector->list command-line-arguments)))
    (init)
    (print-record-for-key (archiver-procedure (car args))
                          (cadr args))))

(define (make-open-hdf5-archive-procedure)
  (lambda (path)
    (make <swarm.defobj.HDF5ArchiverImpl> *globalZone* path)))
