
OBJ =	ddfmodule.o ddfutils.o ddffielddefn.o ddfrecord.o ddffield.o \
	ddfsubfielddefn.o \
	\
	cpl_error.o cpl_vsisimple.o cpl_string.o cpl_conv.o cpl_multiproc.o \
	cpl_vsil.o cpl_vsi_mem.o cpl_vsil_unix_stdio_64.o cpl_dir.o \
	cpl_conv.o cpl_path.o

CXXFLAGS = -O2  -Wall
LIBS 	=  -lm
CXX	= g++


default:	8211view

libiso8211.a:	$(OBJ)
	ar r libiso8211.a $(OBJ)

ddfmodule.o:	ddfmodule.cpp
	$(CXX) -c $(CXXFLAGS) ddfmodule.cpp 

ddfutils.o:	ddfutils.cpp
	$(CXX) -c $(CXXFLAGS) ddfutils.cpp 

ddffielddefn.o:	ddffielddefn.cpp
	$(CXX) -c $(CXXFLAGS) ddffielddefn.cpp 

ddfrecord.o:	ddfrecord.cpp
	$(CXX) -c $(CXXFLAGS) ddfrecord.cpp 

ddffield.o:	ddffield.cpp
	$(CXX) -c $(CXXFLAGS) ddffield.cpp 

ddfsubfielddefn.o:	ddfsubfielddefn.cpp
	$(CXX) -c $(CXXFLAGS) ddfsubfielddefn.cpp 

cpl_error.o:	cpl_error.cpp
	$(CXX) -c $(CXXFLAGS) cpl_error.cpp 

cpl_string.o:	cpl_string.cpp
	$(CXX) -c $(CXXFLAGS) cpl_string.cpp 

cpl_conv.o:	cpl_conv.cpp
	$(CXX) -c $(CXXFLAGS) cpl_conv.cpp 

cpl_vsisimple.o:	cpl_vsisimple.cpp
	$(CXX) -c $(CXXFLAGS) cpl_vsisimple.cpp 

#
#	Mainlines
#

8211view.o:	8211view.cpp
	$(CXX) -c $(CXXFLAGS) 8211view.cpp 

8211dump.o:	8211dump.cpp
	$(CXX) -c $(CXXFLAGS) 8211dump.cpp 

8211view:	8211view.o libiso8211.a
	$(CXX) $(CXXFLAGS) 8211view.o libiso8211.a $(LIBS) -o 8211view

8211dump:	8211dump.o libiso8211.a
	$(CXX) $(CXXFLAGS) 8211dump.o libiso8211.a $(LIBS) -o 8211dump


test:	8211dump
	@./teststream.sh > t1.out
	@if test "`diff t1.out teststream.out`" = '' ; then \
	    echo "******* Stream 1 Succeeded *********"; \
	    rm t1.out; \
	else \
	    echo "******* Stream 1 Failed *********"; \
	    diff t1.out teststream.out; \
	fi
