#python 2.*
#by Ian Ruotsala
#prompt: https://pbs.twimg.com/media/Dfi-vLjUwAAihNw.jpg:large
#https://twitter.com/ian_ruotsala/status/1006766973055840256
#comes out to approx -2.98126835635

import math

DEFAULT_SLICES = 1000000
DEFAULT_START=0
DEFAULT_RANGE=1

def integrate(start, range, slices):
        width=(range*1.0)/(slices*1.0)

        sum = 0.0

        for n in xrange(0,slices):
                x = n*width
                numerator = (3.0*x*x*x-1.0*x*x+2.0*x-4.0)
                denominator = math.sqrt(1.0*x*x-3.0*x+2)
                sum += width*numerator/denominator
                
        return sum
	
result=integrate(DEFAULT_START, DEFAULT_RANGE, DEFAULT_SLICES)
print result
