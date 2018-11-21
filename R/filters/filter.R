ext_filter <- function(d, call, args=c(), ...) {

    stdin <- capture.output(write.table(d, sep="\t", col.names=NA, quote=F, ...))
    stdout <- system2( call, args=args, input=stdin, stdout=T )

    return( read.delim(text=stdout, row.names=1) )

}
