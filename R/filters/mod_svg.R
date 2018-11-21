mod_svg <- function(df, fn_in, basename) {

    if(!require("XML")) install.packages("XML", repos="http://cran.us.r-project.org")
    if(!require("rsvg")) install.packages("rsvg", repos="http://cran.us.r-project.org")
    if(!require("dplyr")) install.packages("dplyr", repos="http://cran.us.r-project.org")
    if(!require("tidyr")) install.packages("tidyr", repos="http://cran.us.r-project.org")
    library(XML)
    library(rsvg)
    library(dplyr)
    library(tidyr)

    xml <- xmlParse(fn_in)

    grad_cols <- c(
        "#0022dd",
        "#ffffff",
        "#dd2200"
    )
    grad_ids <- c(
        "gradient_lower",
        "gradient_middle",
        "gradient_upper"
    )
    pal <- colorRamp(grad_cols)

    #modify legend gradient
    for (i in 1:3) {
        n <- getNodeSet(xml, sprintf('//*[@id="%s"]', grad_ids[i]))
        if (length(n) < 1) {
            stop("missing gradient element")
        }
        xmlAttrs(n[[1]])["stop-color"] <- grad_cols[i]
    }

    lower <- 38
    upper <- 58

    # clamp median Tm values
    df$median[df$median < lower] <- lower
    df$median[df$median > upper] <- upper

    for (i in 1:nrow(df)) {
        id <- as.character( df[i, "symb"] )
        tm <- df[i, "median"]
        if (is.na(id) | is.na(tm)) {
            next
        }
        
        norm <- (tm - lower) / (upper - lower)
        col <- rgb( pal(norm)/255 )

        for (atid in unlist(strsplit(id, "|", fixed=T))) {
            n <- getNodeSet(xml, sprintf('//*[@id="%s"]', atid))
            if (length(n) < 1) {
                next
            }
            xmlAttrs(n[[1]])["fill"] <- col
        }
    }
    svg <- saveXML(xml)

    fn.pdf <- paste0(basename, ".pdf")
    fn.ps  <- paste0(basename, ".ps")
    fn.png <- paste0(basename, ".png")

    rsvg_pdf( charToRaw(svg), fn.pdf )
    rsvg_ps(  charToRaw(svg), fn.ps  )
    rsvg_png( charToRaw(svg), fn.png, width=3000 )

    system2('ps2eps', c('-f', fn.ps))
    file.remove(fn.ps)

}
