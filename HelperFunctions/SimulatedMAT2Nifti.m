function [nii,hdr] = SimulatedMAT2Nifti(img, datatype)
    voxel_size = [3 3 3.7500];
    origin = [32,32,16];
    if nargin < 2
        datatype = 16; % 8 int32, 16 float32, 64 float64
    end
    if (datatype == 8) && ~(isinteger(img))
        INT32_MIN = -2147483648;
        INT32_MAX = 2147483647;
        [img, ~, ~, inv_scale, inv_offset] = scaledata(img, INT32_MIN, INT32_MAX);
    end
    nii = make_nii(img, voxel_size, origin, datatype, 'Simulated with RSA Toolbox');
    if (datatype == 8) && ~(isinteger(img))
        nii.hdr.dime.scl_inter = inv_offset;
        nii.hdr.dime.scl_slope = inv_scale;
    end
    hdr = nii.hdr;
end
