library(shiny)
library(tidyverse)

#1. Load recommender-ready data
rec_features <- read.csv("D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/laptops_recommender_features.csv")
rec_features <- rec_features %>% rename(price = Actual.Price)


#2. Define the recommendation function
recommend_laptops <- function(
    data,
    budget,
    w_price = 0.30,
    w_cpu = 0.25,
    w_ram = 0.20,
    w_storage = 0.15,
    w_gpu = 0.10,
    top_n = 5
) {
  
  total_weight <- w_price + w_cpu + w_ram + w_storage + w_gpu
  if (abs(total_weight - 1) > 0.001) {
    stop("Weights must sum to 1")
  }
  
  candidates <- data %>%
    filter(price <= budget)
  
  if (nrow(candidates) == 0) {
    return(tibble(
      Message = "No laptops found within the given budget."
    ))
  }
  
  candidates %>%
    mutate(
      Final_Score =
        w_price   * Price_Score +
        w_cpu     * CPU_Score +
        w_ram     * RAM_Score +
        w_storage * Storage_Score +
        w_gpu     * GPU_Score
    ) %>%
    arrange(desc(Final_Score)) %>%
    slice_head(n = top_n) %>%
    select(
      Name, Brand, price,
      RAM_GB, Storage_GB,
      CPU_Tier, GPU_Tier,
      Final_Score
    )
}

#3. UI: clean, simple, professional
ui <- fluidPage(
  
  titlePanel("Laptop Recommendation System"),
  
  sidebarLayout(
    
    sidebarPanel(
      sliderInput(
        "budget",
        "Budget",
        min = 100000,
        max = 600000,
        value = 300000,
        step = 10000,
        pre = "PKR "
      ),
      
      h4("Preference Weights (must sum to 1)"),
      
      sliderInput("w_price", "Price Importance", 0, 1, 0.35, step = 0.05),
      sliderInput("w_cpu", "CPU Importance", 0, 1, 0.25, step = 0.05),
      sliderInput("w_ram", "RAM Importance", 0, 1, 0.20, step = 0.05),
      sliderInput("w_storage", "Storage Importance", 0, 1, 0.10, step = 0.05),
      sliderInput("w_gpu", "GPU Importance", 0, 1, 0.10, step = 0.05),
      
      numericInput("top_n", "Number of Recommendations", 5, min = 1, max = 10)
    ),
    
    mainPanel(
      tableOutput("recommendations"),
      textOutput("weight_warning")
    )
  )
)

#4. Server logic
server <- function(input, output) {
  
  output$weight_warning <- renderText({
    total <- input$w_price + input$w_cpu + input$w_ram +
      input$w_storage + input$w_gpu
    
    if (abs(total - 1) > 0.001) {
      paste("⚠️ Weights sum to", round(total, 2), "- please adjust to 1")
    } else {
      ""
    }
  })
  
  output$recommendations <- renderTable({
    
    total <- input$w_price + input$w_cpu + input$w_ram +
      input$w_storage + input$w_gpu
    
    if (abs(total - 1) > 0.001) {
      return(NULL)
    }
    
    recommend_laptops(
      data = rec_features,
      budget = input$budget,
      w_price = input$w_price,
      w_cpu = input$w_cpu,
      w_ram = input$w_ram,
      w_storage = input$w_storage,
      w_gpu = input$w_gpu,
      top_n = input$top_n
    )
  })
}

#5. Run the app
shinyApp(ui = ui, server = server)
