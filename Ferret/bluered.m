function map = redblue(nn)
%function map = redblue(nn)
%produces a red-to-white-to-blue colormap with 'nn' entries (default=64)

if nargin < 1, nn = size(get(gcf,'colormap'),1); end
n1=fix(nn/6);
n2=fix(nn/2) - n1;

map1= [ .5*(1+((1:n1)-1)/n1)'    zeros(n1,1)      zeros(n1,1)  ];
map2= [      ones(n2,1)       ((1:n2)-1)'/n2    ((1:n2)-1)'/n2 ];
map3= [    (n2-(1:n2))'/n2    (n2-(1:n2))'/n2    ones(n2,1)    ];
map4= [      zeros(n1,1)        zeros(n1,1)   (1-.4*(1:n1)/n1)'];
map = [map3; map4; map1; map2];
%map=map(end:-1:1,:);
