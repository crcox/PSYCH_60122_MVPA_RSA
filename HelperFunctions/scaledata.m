function [dataout, scale, offset, inv_scale, inv_offset] = scaledata(datain,minval,maxval)
    scale = (maxval-minval) / range(datain(:));
    offset = (-min(datain(:)*scale)) + minval;
    dataout = (datain * scale) + offset;
    if nargout > 3
        [~,inv_scale, inv_offset] = scaledata(dataout, min(datain(:)), max(datain(:)));
    end
end