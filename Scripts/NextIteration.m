for counter = 1:numIterations
    
    %[v,c]=VoronoiLimit(Px,Py, crs, false);
    [v,c]=VoronoiBounded(Px,Py, crs);
    
    if showPlot
        set(currHandle,'XData',Px,'YData',Py);%plot current position
        for i = 1:numel(Px) % color according to
            xD = [get(pathHandle(i),'XData'),Px(i)];
            yD = [get(pathHandle(i),'YData'),Py(i)];
            set(pathHandle(i),'XData',xD,'YData',yD);%plot path position
            %       set(numHandle(i),'Position',[ Px(i),Py(i)]);
        end
    end
    
    for i = 1:numel(c) %calculate the centroid of each cell
        BW = roipoly(Z,100*v(c{i},1),100*v(c{i},2));
        GI = mat2gray(BW);
        for m=1:1000
            for j=1:1000
                GI(j,m) = GI(j,m)*val2(j,m);
            end
        end
        s = regionprops(BW, GI, {'WeightedCentroid'});
        cx = s.WeightedCentroid(1,1)/100;
        cy = s.WeightedCentroid(1,2)/100;
        cx = min(xrange,max(0, cx));
        cy = min(yrange,max(0, cy));
        if ~isnan(cx) && inpolygon(cx,cy,crs(:,1),crs(:,2))
            Px(i) = cx;  %don't update if goal is outside the polygon
            Py(i) = cy;
        end
    end
    
    if showPlot
        for i = 1:numel(c) % update Voronoi cells
            set(verCellHandle(i), 'XData',v(c{i},1),'YData',v(c{i},2));
        end
        
        set(titleHandle,'string',['o = Robots, + = Goals, Iteration ', num2str(counter,'%3d')]);
        set(goalHandle,'XData',Px,'YData',Py);%plot goal position
        axis equal
        axis([0,xrange,0,yrange]);
        drawnow
    end
end
val = Z;
for i = 1:n
    BW = roipoly(Z,100*v(c{i},1),100*v(c{i},2));
    GI = mat2gray(BW);
    s = regionprops(BW, GI, {'Centroid','WeightedCentroid'});
    for m=1:1000
        for j=1:1000
            vx = s.WeightedCentroid(1,1);
            vy = s.WeightedCentroid(1,2);
            dist = sqrt(((m+0.5)-vx)^2+((j+0.5)-vy)^2)/100;
            if dist < r_sen
                val(j,m) = min(val(j,m),(1-0.8708+0.074*dist^2));
            end
        end
    end
end
for m=1:1000
    for j=1:1000
        Z(j,m) = Z(j,m)*val(j,m);
        val2(j,m) = 2*Z(j,m)*0.074;
    end
end
max_d(k)= max(max(Z));
average(k) = mean2(Z);
k=k+1;