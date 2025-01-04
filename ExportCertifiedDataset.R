library(odbc)

# Build a database connection to the CAKN_BaldEagles Sql Server database
Connection = dbConnect(odbc(),Driver = "Sql Server",Server = "inpyugamsvm01\\nuna", Database = "CAKN_BaldEagles")

# This is the parent directory for certified dataset exports
CertifiedDatasetDirectory = r'(J:\Monitoring\Bald_Eagles\Data\Certified Dataset for IRMA\)'
NewDatasetDirectory = paste(CertifiedDatasetDirectory,Sys.Date(),sep="")

# Function to write a csv
WriteFile = function(DataFrame,Filepath){
  # Use tryCatch to handle potential errors
  result <- tryCatch(
    {
      write.table(DataFrame,Filepath,row.names = FALSE)
      cat("Wrote data frame to ",Filepath,". Succeeded.\n")
    },
    error = function(e) {
      # Handle the error
      cat("An error occurred:", e$message, "\n")
    }
  )
}






# Check if the directory exists
if (!dir.exists(NewDatasetDirectory)) {
  # Ask for user confirmation
  cat("The directory does not exist. Do you want to create it? (yes/no): ")
  user_input <- readline()
  
  # Create the directory if the user confirms
  if (tolower(user_input) == "yes") {
    dir.create(NewDatasetDirectory)
    cat("Directory created:", NewDatasetDirectory, "\n")
  } else {
    cat("Directory not created.\n")
  }
} else {
  cat("Directory already exists:", NewDatasetDirectory, "\n")
  
  # Get the Nests dataset
  Sql = "SELECT Nest_ID
, IsActive
, DiscoverDate
, FirstSightingDate
, LastSightingDate
, DateDiscoveredGone
, Fate
, [Duration (years)]
, RiverSegment
, TreeSpecies
, Species
, TreeIsDead
, NumberOfTimesNotFoundInTheLast2Surveys
, OccupancyObservations
, NestInitiations
, ProductivityObservations
, NumberOfTimesSuccessful
, PctSuccessful
, AvgYoungPerSuccessfulNest
, EarliestOccupancyRecord
, LatestOccupancyRecord
, EarliestProductivityRecord
, LatestProductivityRecord
, Location.Lat AS Lat
, Location.Long AS Lon
, NestSub
, TerritoryID
, Comments
, Convert(Date,GETDATE()) AS VersionDate
FROM Dataset_Nests
ORDER BY Nest_ID"
  Nests = dbGetQuery(Connection,Sql)
  
  # Write the nests dataset to a file
  cat("Attempting to write Nests dataset to file...")
  NestsFilename = paste(NewDatasetDirectory,"/WRST BAEA Certified Nests Dataset Ver. ",Sys.Date(),".csv",sep="")
  WriteFile(Nests,NestsFilename)

  Sql = "SELECT TOP (1000) [Year]
      ,[RiverSegment]
      ,[Nest_ID]
      ,[Date_O]
      ,[Nest_O]
      ,[OccupancyStatus]
      ,[Date_P]
      ,[StatusCode_P]
      ,[ProductivityStatus]
      ,[NumYng]
      ,[NumAds_O]
      ,[AdBehav1_O]
      ,[AdBehav2_O]
      ,[NumEggs_O]
      ,[NumAds_P]
      ,[AdBehav1_P]
      ,[AdBehav2_P]
      ,[Chick_Age]
      ,[NestCondition_O]
      ,[TreeSpecies]
      ,[TreeIsDead]
      ,[NestSub]
      ,[TreeStat]
      ,[NestVis]
      ,[NestComments]
      ,[Park]
      ,[Pilot_O]
      ,[ReObserv_O]
      ,[Aircraft_O]
      ,[ReObserver_P]
      ,[Aircraft_P]
      ,[Pilot_P]
      ,[Comments_O]
      ,[Comments_P]
      ,[DataProcessingComment]
      ,[CertificationLevel]
      ,[Location].Lat as Lat
	  ,Location.Long as Lon
  FROM [CAKN_BaldEagles].[dbo].[Dataset_Productivity]
  WHERE CertificationLevel <> 'Raw'
  ORDER BY Year DESC,Nest_ID"
  ProductivityDataset = dbGetQuery(Connection,Sql)
    
  # Write the productivity dataset to a file
  cat("Attempting to write Productivity dataset to file...")
  ProductivityFilename = paste(NewDatasetDirectory,"/WRST BAEA Certified Productivity Dataset Ver. ",Sys.Date(),".csv",sep="")
  WriteFile(ProductivityDataset,ProductivityFilename)

}





