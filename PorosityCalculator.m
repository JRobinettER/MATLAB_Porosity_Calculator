clear
clc
close all
%% Getting user inputs
%Get the name of the file the user would like to use
ImageInputName = input("Please input the name of the image you wish to use, excluding the identifying number at the end and the file type appendix.\n", "s");
while ImageInputName == ""
    ImageInputName = input("Please input the name of the image you wish to use, excluding the identifying number at the end and the file type appendix.\n", "s");
end
%Ask the user how many images they would like to use and store that number
ImageCount = input("Please input the number of images you wish to process. \n");
while ImageCount <= 0
    ImageCount = input("Please input the number of images you wish to process. \n");
end
%Ask the user which image they would like to start at and store that number
ImageStart = input("Please input the number of the first image you would like to process. \n");
while ImageStart < 1
    ImageStart = input("Please input the number of the first image you would like to process. \n");
end
%Retrieve the first image to check sizing (requires jpg format)
ImageUseTest = string(ImageInputName) + string(ImageStart) + ".jpg";
%Display the sizing for the user to see
fprintf("The current size of your first image is %.0f by %.0f \n", height(imread(ImageUseTest)), width(imread(ImageUseTest)))
%Run a check FIRST to make sure the user does not want to just use
%the base image
SizeCheck = input("Would you like your images resized or not? 0: Base dimensions; 1: Resized\n");
while isempty(SizeCheck)
    SizeCheck = input("Would you like your images resized or not? 0: Base dimensions; 1: Resized\n");
end
if (SizeCheck <= 0)
    SizeCheck = 0;
    FinalImage = zeros([height(imread(ImageUseTest)), width(imread(ImageUseTest))], "uint8");
elseif (SizeCheck > 0)
    %Request the values for the height and width of the images, in case the
    %user would like to set a standard size
    StandardSizeY = input("Please input a value for the height of the images to be used (>= 100px) \n");
    while StandardSizeY < 100
        StandardSizeY = input("Please input a value for the height of the images to be used (>= 100px) \n");
    end
    StandardSizeX = input("Please input a value for the width of the images to be used. (>= 100px) \n");
    while StandardSizeX < 100
        StandardSizeX = input("Please input a value for the width of the images to be used. (>= 100px) \n");
    end
    FinalImage = zeros([StandardSizeX, StandardSizeY], "uint8");
end
%Request from the user what their intent is in using the program to then
%direct the program towards that use
WhileLoopPurposeCheck = 0;
while WhileLoopPurposeCheck == 0
    PurposeCheck = input("Please indicate what function of this program you would like to use with just its number:\n      (1) Check sensitivity values \n      (2) Generate images \n     " + ...
        " (3) Obtain just porosity and pore aspect ratio data\n");
    switch PurposeCheck
        case 1
            fprintf("You have chosen to check sensitivity values. \n")
            SensitivityBottom = input("Please enter the first sensitivity value you would like to check \n");
            while SensitivityBottom <= 0
                SensitivityBottom = input("Please enter the first sensitivity value you would like to check \n");
            end
            SensitivityTop = input("Please enter the final sensitivity value you would like to check \n");
            while SensitivityTop <= SensitivityBottom
                SensitivityTop = input("Please enter the final sensitivity value you would like to check \n");
            end
            ImageCheck = 0;
            %Setting the senstivity range so that the program can then
            %determine how big of arrays it needs to make
            SensitivityRange = SensitivityTop - SensitivityBottom;
            WhileLoopPurposeCheck = 1;
        case 2
            fprintf("You have chosen to generate images. \n")
            Sensitivity = input("Please input a sensitivity value between 1 and 255 to use.\n");
            while Sensitivity <= 0 || Sensitivity > 255
                Sensitivity = input("Please input a sensitivity value between 1 and 255 to use.\n");
            end
            %Setting the senstivity range so that the program can then
            %determine how big of arrays it needs to make
            SensitivityRange = 0;
            SensitivityTop = Sensitivity;
            SensitivityBottom = Sensitivity;
            WhileLoopPurposeCheck = 1;
            ImageCheck = 1;
        case 3
            fprintf("You have chosen to obtain just porosity and pore aspect ratio data. \n")
            Sensitivity = input("Please input a sensitivity value between 1 and 255 to use.\n");
            while Sensitivity <= 0 || Sensitivity > 255
                Sensitivity = input("Please input a sensitivity value between 1 and 255 to use.\n");
            end
            %Setting the senstivity range so that the program can then
            %determine how big of arrays it needs to make
            ImageCheck = 0;
            SensitivityRange = 0;
            SensitivityTop = Sensitivity;
            SensitivityBottom = Sensitivity;
            WhileLoopPurposeCheck = 1;
        otherwise
            WhileLoopPurposeCheck = 0;
    end
end
%% Setting up variables
%Set up the counter for the loops
loopcounter = 0;
%Setting up the categories for the table to be displayed
Porosity = zeros(SensitivityTop, 1);
PoreRatio = zeros(SensitivityTop, 1);
%Making a blank array for the changed image map
NewMap = [0; 0; 0];
%Setting up matrices to output to the Excel file
ExcelMatrixPorosity = zeros(SensitivityTop, ImageCount);
ExcelMatrixPoreRatio = zeros(SensitivityTop, ImageCount);
%% Running the code
%Runs the for loop for the number of images to be processed, regardless of
%the intent of the user
for A = ImageStart:(ImageCount + ImageStart - 1)
    %Setting the name of the image to be used to what the user requested
    ImageUse = ImageInputName + string(A) + ".jpg";
    %Define standard size if the user would like to use the base image or
    %the resized image
    if (SizeCheck <= 0)
        %Read the image without the scales applied
        baseImage = imread(ImageUse);
    else
        %Read the image without the scales applied
        baseImage = imread(ImageUse);
        %Standard size defined
        StandardSize = [StandardSizeX, StandardSizeY, 0];
        %Read the image with the scales applied
        baseImage = imresize(baseImage, [StandardSize(2), StandardSize(1)]);
    end
    %Here we are using another for loop to run over the range
    %the user requested. If the range is just 1, then the loop will only run
    %once because the top value is the range value

    %The range depends on the functionality the user has chosen
    if SensitivityRange == 0
        BottomValue = SensitivityBottom;
        TopValue = SensitivityTop;
    end
    if SensitivityRange > 0
        BottomValue = SensitivityBottom;
        TopValue = SensitivityTop;
    end
    for P = BottomValue:TopValue
        %Turn the image into a grayscale
        GrayImage = im2gray(baseImage);
        %Using the method of centroids to attempt to find the pores
        %Here we convert the image to a black and white image, and here
        %is where we must determine what value of sensitivity is to be
        %used
        if (SensitivityRange == 0)
            %If the user only chose one sensitivity value, then the
            %range is just 1 and the program will only use the sensitivity
            %value the user requested
            BW =  (GrayImage) < Sensitivity;
        end
        if (SensitivityRange > 0)
            %If there are a range of sensitivity values to be checked, the
            %program will run the loop multiple times and the image will
            %use each sensitivity value as it loops
            BW =  (GrayImage) < P;
        end
        %Find the centroid of each pore
        C = regionprops(BW, GrayImage, {'Centroid'});
        %Now we need to calculate the total area the pores occupy
        counter = 0;
        for i = 1:numel(BW)
            if (BW(i) == 1)
                counter = counter + 1;
            end
        end
        %We need to generate images and edges ONLY if the user desires so
        if (ImageCheck > 0)
            %This while loop will ensure that for the entirety of the matrix of centers
            %each array is used
            k = 1;
            while k <= numel(C)
                %Creating the edges here to be outputted to the image
                BWs = bwperim(BW, 8);
                %Increase thickness here
                se = strel('disk', 3);
                thickerEdges = imdilate(BWs, se);
                NewMap = baseImage;
                %Highlight all areas that match in red
                NewMap(thickerEdges) = 255;
                k = k+1;
            end
            hold on
            %Displays the images
            imshow(NewMap)
            hold off
        end
        %Calculating the porosity and adding it to its respective array
        Porosity(P, 1) = (counter)/numel(BW);
        %Getting the major and minor axis lengths
        lengths = regionprops(BW, "MajorAxisLength", "MinorAxisLength");
        %Taking their means
        diametersMa = mean([lengths.MajorAxisLength]);
        diametersMi = mean([lengths.MinorAxisLength]);
        %Calculating the ratio
        totalDiameterValue = diametersMa/diametersMi;
        %Adding the pore aspect ratio to its respective array
        PoreRatio(P, 1) = totalDiameterValue;
        %Pushing the porosity and pore aspect ratio values to the excel matrix
        for f = BottomValue:TopValue
            ExcelMatrixPorosity(f, A) = Porosity(f, 1);
        end
        for g = BottomValue:TopValue
            ExcelMatrixPoreRatio(g, A) = PoreRatio(g, 1);
        end
        %Presenting the number of steps left
        loopcounter = loopcounter + 1;
        if (SensitivityRange ~= 1)
            fprintf("\n completed step %d of %d", loopcounter, (SensitivityRange + 1) * (ImageCount))
        end
    end
end
%% Exporting to Excel
%Display table of values to Excel
filename = "PorosityPoreRatioDataTest.xlsx";
writematrix(ExcelMatrixPorosity, filename, "Sheet", "Porosity");
writematrix(ExcelMatrixPoreRatio, filename, "Sheet", "PoreRatio");
writematrix(ExcelMatrixPorosity, filename, "Sheet", "PorosityCropt");
writematrix(ExcelMatrixPoreRatio, filename, "Sheet", "PoreRatioCropt");
