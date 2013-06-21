-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

print("Loading friction_models.lua")

-- clamp values to an ellipse
function friction_ellipse (x, x_max, y, y_max)
        x = x / x_max
        y = y / y_max
        local r = math.sqrt(x*x + y*y)
        if r < 1 then r = 1 end
        x = x_max * x / r
        y = y_max * y / r
        return x, y, clamp(r-2, 0, 1)
end

function friction_model_lateral (P,A,B, forward_speed, right_speed, load)

        local sign = sign(right_speed)
        local slip_angle = math.deg(math.atan(math.abs(right_speed), math.abs(forward_speed)))
        -- slip_angle always between 0 and 90
        local force = load * (B * slip_angle) / (1 + A * math.pow(slip_angle, P));
        force = force * -sign
        return force
end

