# ------------------------------------
# --------- LUCIFER SOURCES ----------
# ------------------------------------

import numpy
import math

def get_src_par():
	pars = {
		'field':0, 				# Ex
		'type':1,				# plane wave250
		'direction':2,				# 0=X; 1=Y; 2=Z;
		'location':(0,0,95)			# at z, x, y are irrelevant see add_source.c
	}

	return pars

def get_time_profile(t_buf, simp):
	dt = numpy.dtype(numpy.float32)
	dt = dt.newbyteorder('<')
	t = numpy.frombuffer(t_buf,dtype=dt)
	C0 = simp['C0']
	delta_t = simp['dt']
	max_time = simp['max_time']
	
	for i in xrange(0, max_time-1):
		#t[i] = math.sin(2*numpy.pi*0.5e15*i*delta_t)
		t[i] = -(i-500)*numpy.exp(-((i-500)*delta_t/0.125e-12)**2)

