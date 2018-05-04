% Define blur kernel
hsize = 17;
sigma = 5; % Whatever
kernel = fspecial('gaussian',5)
mean(reshape(kernel,1,[]))
kernel