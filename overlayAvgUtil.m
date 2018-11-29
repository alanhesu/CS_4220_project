function overlayAvgUtil(num, avg, name)	
	hold on;
	lgdstr = {};
	p = zeros(num);
	for i = 1:num
		p(i) = plot(avg(:,i*2-1),avg(:,i*2));
		lgdstr{i} = sprintf([name, '%d'], i);
		legend(p(1:i), lgdstr(1:i));
	end
	xlabel('Time (s)');
	ylabel('%');
	title([name, ' Utilization']);
	set(gca, 'FontSize', 18);
	ylim([0,100]);
end