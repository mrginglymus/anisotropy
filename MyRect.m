
classdef MyRect
    properties
        x1
        x2
        y1
        y2
    end
    methods
        
        function obj = MyRect( x1, x2, y1, y2 )
            obj.x1 = x1;
            obj.x2 = x2;
            obj.y1 = y1;
            obj.y2 = y2;
        end
        
        function w = w( obj )
            w = obj.x2-obj.x1;
        end
        
        function h = h( obj )
            h = obj.y2-obj.y1;
        end
        
        function xc = xc( obj )
            xc = (obj.x1 + obj.x2)/2;
        end
        
        function yc = yc( obj )
            yc = (obj.y1 + obj.y2)/2;
        end
        
        function obj = resize( obj, w, h )
            xc = floor( obj.xc );
            obj.x1 = ceil( xc-w/2 );
            obj.x2 = floor( xc+w/2 );
            yc = floor( obj.yc );
            obj.y1 = ceil( yc-h/2 );
            obj.y2 = floor( yc+h/2 );
        end
        
        function showRect( obj, c )
            rectangle( 'Position', [ obj.x1, obj.y1, obj.w, obj.h ],...
    'EdgeColor', c );
        end
        
        function im = cutim( obj, im )
            im = im( obj.y1:obj.y2, obj.x1:obj.x2 );
        end
        
        function obj = shiftx( obj, d )
            obj.x1 = obj.x1 - d;
            obj.x2 = obj.x2 - d;
        end
        
        function obj = shifty( obj, d )
            obj.y1 = obj.y1 + d;
            obj.y2 = obj.y2 + d;
        end
        
        function obj = shift( obj, d, v )
            if strcmp( d, 'x' )
                obj.x1 = obj.x1 - v;
                obj.x2 = obj.x2 - v;
            elseif strcmp( d, 'y' )
                obj.y1 = obj.y1 + v;
                obj.y2 = obj.y2 + v;
            end
        end
                
        
    end
end