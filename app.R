install.packages('remotes')
install.packages('shiny')
install.packages('shinyjs')
install.packages('ggplot2')
install.packages('rlang')
install.packages('rsconnect')
install.packages('remotes')


remotes::install_github("paulc91/shinyauthr")

library(shiny)
library(shinyauthr)
library(shinyjs)
library(ggplot2)
library(rlang)
library(rsconnect)


# dataframe that holds usernames, passwords and other user data
user_base <- data.frame(
  user = c("user1", "user2"),
  password = c("password1", "password2"), 
  permissions = c("admin", "standard"),
  name = c("User One", "User Two"),
  stringsAsFactors = FALSE,
  row.names = NULL
)

ui <- fluidPage(
  # must turn shinyjs on
  shinyjs::useShinyjs(),
  # add logout button UI 
  div(class = "pull-right", logoutUI(id = "logout")),
  # add login panel UI function
  loginUI(id = "login"),
  # output elements for user info and visualizations
  tableOutput("user_table"),
  plotOutput("example_plot"),
  tableOutput("example_data")
)

server <- function(input, output, session) {
  
  # call the logout module with reactive trigger to hide/show
  logout_init <- callModule(shinyauthr::logout, 
                            id = "logout", 
                            active = reactive(credentials()$user_auth))
  
  # call login module supplying data frame, user and password cols
  # and reactive trigger
  credentials <- callModule(shinyauthr::login, 
                            id = "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password,
                            log_out = reactive(logout_init()))
  
  # pulls out the user information returned from login module
  user_data <- reactive({credentials()$info})
  
  output$user_table <- renderTable({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    user_data()
  })
  
  output$example_plot <- renderPlot({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    # example plot
    ggplot(mtcars, aes(x = wt, y = mpg)) +
      geom_point() +
      theme_minimal() +
      labs(title = "Example Scatter Plot", x = "Weight", y = "Miles per Gallon")
  })
  
  output$example_data <- renderTable({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    # example data table
    head(mtcars)
  })
}

shinyApp(ui = ui, server = server)

