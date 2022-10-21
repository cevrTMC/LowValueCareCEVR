library(shiny)
library(dplyr)
library(statebins)
library(colorspace)
library(rgdal)
library(ggiraph)
library(shinycssloaders)
library(ggplot2)
library(ggrepel)
library(hrbrthemes)
library(scales)
library(gridExtra)
library(Cairo)
library(formattable)
library(readxl)


#.libPaths('C:/Users/lliang1/Rpackage')
#setwd('G:/CEVR/LowValue')

ui_barwidth = 16
tooltip_css <- "background-color:gray;color:white;padding:10px;border-radius:10px 20px 10px 20px; font-family: Courier New;"
data <- read.csv("lvsData.csv")
meta = read_excel("lvc_category.xlsx")

ords = c(
  "PSA testing",
  "Cervical cancer screening",
  "Colorectal cancer screening",
  "Cancer screening for patients with CKD",
  "Bone mineral density testing",
  "Homocysteine testing",
  "Hypercoagulability testing",
  "T3 level testing",
  "Preoperative chest radiography",
  "Preoperative echocardiography",
  "Preoperative pulmonary function testing",
  "Preoperative stress testing",
  "Cardiac tests before cataract surgery",
  "Brain CT or MRI for headache",
  "Imaging for lower back pain",
  "Imaging for plantar fasciitis/heel pain",
  "Cardiac stress testing",
  "IVC filters",
  "PCI with balloon angioplasty",
  "Renal/visceral angioplasty",
  "Vertebroplasty or kyphoplasty",
  "Arthroscopic surgery",
  "Spinal injection"
)

ord_service = function(s){
  f1 = factor(s, levels=ords)
  return(as.character(sort(f1)))
}

ordered_cat = function(s){
  ord = c("Cancer Screenings","Diagnostic & Preventive Testing","Preoperative Testing","Imaging","Cardiovascular Testing & Procedures","Musculoskeletal Surgeries & Procedures")
  f1 = factor(s, levels=ord)
  return(as.character(sort(f1)))
}

metric_map = function(s){
  m = c("Utilization Rate"="Utilization rate (per 100,000 eligible enrollees)","Procedure Price"="Procedure price ($USD)","Overall Spending"="Overall spending ($USD per 100,000 eligible enrollees)")
  return (as.character(m[s]))
}

plot_price = function(df){
  if(is.null(df$procprice)) return(NA)
  sum_stat= summary(df$procprice)
  
  pmin = floor(as.numeric(sum_stat[1])/10)*10
  pmax = ceiling(as.numeric(sum_stat[6])/10)*10
  # if all NAs
  if(sum(length(which(is.na(df$procprice))))==51)
  {
    pmin=0
    pmax=100
  }
  
  breaks = seq(pmin, pmax, floor((pmax-pmin)/4))
  
  gg=ggplot(df, aes(state=STATE, fill=procprice)) +
    geom_statebins()+ 
    coord_equal(.95)+ 
    theme_statebins(legend_position = "bottom", base_size = 9)+ 
    theme(legend.title.align = 0.5, legend.title = element_text(face = "bold"))+
    scale_fill_continuous_sequential(name="Price in $USD\n(Per procedure)", limits=c(pmin,pmax), breaks = breaks, palette = "Blues", labels=comma_format())+ 
    guides(fill = guide_colourbar(frame.colour = "black", barwidth = ui_barwidth, barheight = 1, ticks.colour = "black", raster=TRUE))+ 
    theme(legend.text=element_text(family="TT Courier New", size=9), legend.title =element_text(family="TT Courier New"))
  #ggsave(filename = "Agg_Price.pdf", device = cairo_pdf, dpi = 600)
  return(gg)
}

plot_spend= function(df){
  if(is.null(df$spending)) return(NA)
  
  sum_stat= summary(df$spending)
  
  pmin = floor(as.numeric(sum_stat[1])/10)*10
  pmax = ceiling(as.numeric(sum_stat[6])/10)*10
  # if all NAs
  if(sum(length(which(is.na(df$spending))))==51)
  {
    pmin=0
    pmax=100
  }
  
  breaks = seq(pmin, pmax, floor((pmax-pmin)/4))
  
  gg=ggplot(df, aes(state=STATE, fill=spending)) +
    geom_statebins()+ 
    coord_equal(.95)+ 
    theme_statebins(legend_position = "bottom", base_size = 9)+ 
    theme(legend.title.align = 0.5, legend.title = element_text(face = "bold"))+
    scale_fill_continuous_sequential(name="Spending in $USD\n(per 100,000 eligible enrollees)", limits=c(pmin,pmax), breaks = breaks, palette = "Greens",labels=comma_format())+ 
    guides(fill = guide_colourbar(frame.colour = "black", barwidth = ui_barwidth, barheight = 1, ticks.colour = "black", raster=TRUE))+
    theme(legend.text=element_text(family="TT Courier New", size=9), legend.title =element_text(family="TT Courier New"))
  #ggsave(filename = "Agg_Spend.pdf", device = cairo_pdf, dpi = 600)
  return(gg)  
}

plot_util= function(df){
  if(is.null(df$utilization)) return(NA)
  sum_stat= summary(df$utilization)
  pmin = floor(as.numeric(sum_stat[1]))
  pmax = ceiling(as.numeric(sum_stat[6]))
  # if all NAs
  if(sum(length(which(is.na(df$utilization))))==51)
  {
    pmin=0
    pmax=100
  }
  
  breaks = seq(pmin, pmax, floor((pmax-pmin)/4))
  print("plot_util runing")
  gg=ggplot(df, aes(state=STATE, fill=utilization)) +
    geom_statebins()+ 
    coord_equal(.95)+ 
    theme_statebins(legend_position = "bottom", base_size = 9)+ 
    theme(legend.title.align = 0.5, legend.title = element_text(face = "bold"))+
    scale_fill_continuous_sequential(name="Utilization Rate\n(per 100,000 eligible enrollees)", limits=c(pmin,pmax), breaks = breaks, palette = "Reds", labels=comma_format())+ 
    guides(fill = guide_colourbar(frame.colour = "black", barwidth = ui_barwidth, barheight = 1, ticks.colour = "black", raster=TRUE))+
    theme(legend.text=element_text(family="TT Courier New", size=9), legend.title =element_text(family="TT Courier New"))
  #ggsave(filename = "Agg_Util.pdf", device = cairo_pdf, dpi = 600)
  print("plot_util end")
  return(gg)  
}

coord= function(d){
  xmin=as.numeric(d["xmin"])
  xmax=as.numeric(d["xmax"])
  ymin=as.numeric(d["ymin"])
  ymax=as.numeric(d["ymax"])
  
  x1=c(xmin, xmin, xmax,xmax,xmin)
  y1=c(ymin,ymax,ymax, ymin,ymin)
  sp::Polygon(cbind(x1,y1))
}

process_gg = function(gg){
  dg <- layer_data(gg)
  # convert each data frame to a Polygon class object
  polygons =apply(dg,1,coord)
  # convert each Polygon class object to Polygons class object
  polygons <- lapply(seq_along(polygons), 
                     function(i){
                       Polygons(list(polygons[[i]]),
                                ID = i)
                     })
  # convert list of Polygons class object to one SpatialPolygons object
  polygons <- SpatialPolygons(polygons)
  return(polygons)
}

processNA = function(df,msg){
  out=df$tooltip
  if(is.null(length(out))) return(out)
  for(i in 1:length(out)){
    if(df$output[i]=="NaN"){
      state = df$state[i]
      out[i] = paste(state,"lacks sufficient data to calculate the","\n", msg)
    }
  }
  return(out)
}


getServieDesc = function(s){
  meta$description[meta$label==s]
}

# Define UI  ----
ui <- fluidPage(
  tags$style(HTML('body {font-family:"TT Courier New",Georgia,Serif; background-color:white}')),
  
  titlePanel(
    h2("State-Level Variation in Low-Value Care for Commercially-Insured and Medicare Advantage Populations", align="center")
  ),
  br(),
  br(),
  # Create a new Row in the UI for selectInputs
  fluidRow(
    column(4,
           selectInput("cat",
                       "Low-Value Service Category:",
                       c(
                         ordered_cat(as.character(unique(data$category)))))
    ),
    column(4,
           uiOutput("service")
    ),
    
    column(4,
           selectInput("metrics",
                       "Metric:",
                       c(metric_map("Utilization Rate"),metric_map("Procedure Price"),metric_map("Overall Spending")
                       ))
    )),
  
  fluidRow(
    
    column(12,
           sliderInput("range", "Year:",
                       min = 2009, max = 2019,sep = "",
                       value = c(2009,2019)))
  ),
  br(),
  br(), 
  fluidRow(column(10, align="center",
                  htmlOutput("summary"))
  ),
  
  br(),
  
  
  fluidRow(
    column(10, ggiraphOutput("Plot_ly", width = "100%",height = "600px")%>% 
             withSpinner(color="#0dc5c1"))
  )
  
)

# Define server logic ----
server <- function(input, output,session) {
  
  subdata = reactive({
    if(class(input$service)=="NULL") return(df)
    df <- data
    df$service= df$label
    if(input$cat!="All"){
      df = df[df$category==input$cat,]
    }
    if(class(input$service)=="NULL") return(df)
    if (input$service != "All") {
      df <- df[df$service==input$service,]
    }
    if(nrow(df)==0) return(data)
    
    df$cat = input$cat
    df$service=input$service
    df$range1 = input$range[1]
    df$range2 = input$range[2]
    df = df[df$year >=as.numeric(input$range[1]) & df$year<=as.numeric(input$range[2]),]
    print("input df")
    info=data.frame(category=input$cat, service=input$service,year_start=input$range[1], year_end=input$range[2],n=nrow(df))
    print(info)
    # write.csv(df,"input_df.csv")
    df$den_COM_MCR = df$den_COM + df$den_MCR
    df$num_COM_MCR = df$num_COM + df$num_MCR
    df$tc_COM_MCR = 0.5*(df$mean_tc_COM+df$mean_tc_MCR)
    df_agg = df%>%group_by(STATE)%>%summarize(den_COM_MCR=sum(den_COM_MCR,na.rm=TRUE),num_COM_MCR=sum(num_COM_MCR, na.rm=TRUE),procprice = mean(tc_COM_MCR, na.rm=TRUE))
    df_agg$utilization = df_agg$num_COM_MCR / df_agg$den_COM_MCR*100000
    df_agg$spending=df_agg$utilization*df_agg$procprice
    
    #  write.csv(df_agg,"input_df_agg.csv")
    
    df_agg
  })
  
  output$service = renderUI({
    if(is.null(input$cat)) return (NA)
    if(input$cat=="All"){
      services= c("All",ord_service(unique(as.character(data$label))))
    }
    else{                  
      services= c("All",ord_service(unique(data$label[data$category==input$cat])))
    }
    selectInput("service",
                "Low-Value Care Service:",
                c(services)                 
    )
  })
  
  output$Plot_ly =  renderggiraph({
    print("enter render ggiraph")
    if(input$metrics==metric_map("Utilization Rate"))
      gg=plot_util(subdata())
    if(input$metrics==metric_map("Procedure Price"))
      gg=plot_price(subdata())
    if(input$metrics==metric_map("Overall Spending"))
      gg=plot_spend(subdata())
    print("gg is created")
    print(class(gg)[1])
    print(class(gg)[1]=="gg")
    print(gg$layer)
    if(class(gg)[1]=="gg"){
      print("after if check")
      dg <- layer_data(gg,i=1)
      print("layer_date is ok")
      # merge with subdata()
      print("before metric check")
      df = merge(subdata(),dg, by.x="STATE", by.y="abbrev")
      if(input$metrics==metric_map("Utilization Rate")){
        df$output = df$utilization
        df$output = comma(df$output, digits=0)
        df$tooltip = c(paste(df$state,"\n",df$output, "per 100,000 eligible enrollees"))
        df$tooltip = processNA(df, metric_map("Utilization Rate"))
      }
      if(input$metrics==metric_map("Procedure Price")){
        df$output= df$procprice
        df$output = currency(df$output,digits=0)
        df$tooltip = c(paste(df$state,"\n",df$output,"per procedure"))
        df$tooltip = processNA(df,metric_map("Procedure Price"))
      }
      if(input$metrics==metric_map("Overall Spending")){
        df$output = df$spending
        df$output = currency(df$output,digits=0)
        df$tooltip = c(paste(df$state,"\n",df$output,"Per 100,000 eligible enrollees"))
        df$tooltip = processNA(df, metric_map("Overall Spending"))
      }
      print("before gg+interactive")
      gg = gg+ geom_point_interactive(aes(tooltip = df$tooltip, x=df$x, y=df$y), size = 5,alpha = 0.01)+ labs(title ="")+xlab("")
    }
    ggiraph(code = print(gg),tooltip_extra_css = tooltip_css,options = list(opts_selection(type = "single", only_shiny = TRUE)) )
  })  
  
  output$summary = renderText({
    if(class(input$service)=="NULL") return("Cat Not ready")
    HTML(paste0(
      "<b>",
      input$cat,
      "</b>",
      "<br>",
      getServieDesc(input$service)
    ))
  })
  
  #  output$description = renderText({
  #    return("Service Not ready")
  #  })  
}

# Create Shiny app ----
shinyApp(ui, server)