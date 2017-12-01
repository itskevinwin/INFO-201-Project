shinyServer(function(input, output) {
  output$text <- renderText({
    paste0("hi")
  })
  output$max <- 100
  output$min <- 30
  output$label <- "label"
})