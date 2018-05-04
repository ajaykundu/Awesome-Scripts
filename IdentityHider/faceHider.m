% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();
img = imread('emo.png');
% Create the point tracker object.
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Create the webcam object.
cam = webcam();

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

runLoop = true;
numPts = 0;
frameCount = 0;

while runLoop && frameCount < 5000

    % Get the next frame.
    videoFrame = snapshot(cam);
    size(videoFrame)
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

    if numPts < 10
        % Detection mode.
        bbox = faceDetector.step(videoFrameGray);

        if ~isempty(bbox)
            % Find corner points inside the detected region.
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

            % Re-initialize the point tracker.
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);

            % Save a copy of the points.
            oldPoints = xyPoints;

            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners. This
            % is needed to be able to transform the bounding box to display
            % the orientation of the face.
            bboxPoints = bbox2points(bbox(1, :));

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the detected face.
            imageplacing = 'Polygon';
           % videoFrame = insertShape(videoFrame, imageplacing, bboxPolygon, 'LineWidth', 3);
           bboxPolygon;
            ltx = round(bboxPolygon(1));
            lty = round(bboxPolygon(2));
            lbx = round(bboxPolygon(3));
            lby = round(bboxPolygon(4));
            rbx = round(bboxPolygon(5));
            rby = round(bboxPolygon(6));
            rtx = round(bboxPolygon(7));
            rty = round(bboxPolygon(8));
            
            numrows = round(lbx - ltx);
            numrows = numrows + 5;
            numcolms =round(rty - lty);
            numcolms = numrows + 5;
            
            img = imresize(img,[numrows numcolms]);
            size(videoFrame);
           
            for k=1:3
                for i=ltx:lbx
                    for j=lty:rty   
                        
                       if img((j-lty + 1),(i-ltx + 1),k)>10 && (i<540 && j<480) && (i>0 && j>150) 
                       videoFrame(j-150,i+100,k) = videoFrame(j,i,k);     
                       end
                       if img((j-lty + 1),(i-ltx + 1),k)>20 && (i<640 && j<480) && (i>0 && j>0) 
                       videoFrame(j,i,k) = img((j-lty + 1),(i-ltx + 1),k);
                       end
                    end
                end
            end
            
            % Display detected corners.
            %videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        end

    else
        % Tracking mode.
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);

        numPts = size(visiblePoints, 1);

        if numPts >= 10
            % Estimate the geometric transformation between the old points
            % and the new points.
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);

            % Apply the transformation to the bounding box.
            bboxPoints = transformPointsForward(xform, bboxPoints);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape.
            bboxPoints;
            bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the face being tracked.
           % videoFrame = insertShape(videoFrame, imageplacing, bboxPolygon, 'LineWidth', 3);
            bboxPolygon;
            ltx = round(bboxPolygon(1));
            lty = round(bboxPolygon(2));
            lbx = round(bboxPolygon(3));
            lby = round(bboxPolygon(4));
            rbx = round(bboxPolygon(5));
            rby = round(bboxPolygon(6));
            rtx = round(bboxPolygon(7));
            rty = round(bboxPolygon(8));
            
            numrows = round(lbx - ltx);
            numrows = numrows + 5;
            numcolms =round(rty - lty);
            numcolms = numrows + 5;
            
            img = imresize(img,[numrows numcolms]);
            size(videoFrame);
           videoFrame(lty:rty,ltx:lbx,1:3) =  imgaussfilt(videoFrame(lty:rty,ltx:lbx,1:3), 2);
             %videoFrame =imgaussfilt(videoFrame(ltx:lbx,lty:rty), 2);
            for k=1:3
                for i=ltx:lbx
                    for j=lty:rty   
                        if img((j-lty + 1),(i-ltx + 1),k)>10 && (i<540 && j<480) && (i>0 && j>150) 
                       videoFrame(j-150,i+100,k) = videoFrame(j,i,k);     
                       end
                       if img((j-lty + 1),(i-ltx + 1),k)>20 && (i<640 && j<480) && (i>0 && j>0) 
                       videoFrame(j,i,k) = img((j-lty + 1),(i-ltx + 1),k);
                       end
                    end
                end
            end
            
            % Display tracked points.
           % videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

            % Reset the points.
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end

    end
   % imgaussfilt(I, 2);
   
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end

% Clean up.
clear cam;
release(videoPlayer);
release(pointTracker);
release(faceDetector);