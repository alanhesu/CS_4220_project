function f = findPeak(x, y)
    ans = [];
    offset = 5;
    for i = 1 : length(y)-offset
        j = i+offset-1;
        window = y(i:j);
        %disp(window);
        avg = mean(window);
        if y(j+1) > avg
            [ans, x(j+1)];
        end
    end
    f = ans;
end