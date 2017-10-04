function Y = buildY(y,k)

Y = zeros(length(y),k);
for(i = 1:k)
    Y(i+1:end,i) = -y(1:end-i);
end