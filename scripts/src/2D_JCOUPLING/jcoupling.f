C
C J-interp program. Pedro Salvador, Institute of Computational Chemistry
C                                            University of Girona, Spain
C                                                               Jan 2011
	program interpo               
	implicit double precision (a-h,o-z)
	dimension G(5000,20),ipo(4)
	dimension dat(50000,2)
	character*10 phi0,psi0
        character*80 line
	
        ilog=0

C USAGE:
C -Compile source file inter.f with a f77 compiler. For instance
C  pgf77 -o interp.x interp.f
C
C -Unrar GRIDS.rar. File grid_x_y contain 2D-grids for J-coupling between atoms X and Y,
C according to labels on Fig 1 of accompanying paper.
C
C -Copy desired grid_x_y file to file GRID
C
C -See accompanying DATA file. The program will calculate interpolated J values between
C  atoms X and Y for all phi,psi pairs of values provided (free format)
C
C -Execute the program by using ./interp.x
C  Interpolated J values will be displayed on the standard output. The average value
C  is also computed.
C
C Notes: average value
C  Interpolated J coupling could also be calculated for a single pair of phi, psi values
C  given as argument, namely  ./interp.x phi_value psi_value
C  In this case uncomment the next line 
C  ilog=1

c READING grid data
        ii=1
	jval=1
c number of J couplings in Grid file
	open(1,file="GRID",err=2)
        read(1,'(a80)') line
1	read(1,*,end=2) (G(ii,k),k=1,2+jval)
        ii=ii+1
	go to 1
2	continue
        ngrid=ii-1

        if(ilog.eq.1) then
c getting phi and psi values as arguments...
	call getarg(1,phi0)
        read(phi0,'(f10.5)') phi
	call getarg(2,psi0)
	read(psi0,'(f10.5)') psi
c calling interpolation function
	write(*,'(f9.4)') xinterp2(phi,psi,ngrid,G)

        else
        
        ii=1
	open(2,file="DATA",err=22)
12	read(2,*,end=22) (dat(ii,k),k=1,2)
        ii=ii+1
	go to 12
22	continue
        ndat=ii-1 

c calling interpolation function
        aver=0.0d0
	do kk=1,ndat
         phi=dat(kk,1)
         psi=dat(kk,2)
 	 xj=xinterp2(phi,psi,ngrid,G)
         aver=aver+xj
c	 write(*,'(3(f11.4))') phi,psi,xj
	 write(*,'(f11.4)') xj
        end do
        aver=aver/ndat
c        write(*,*) '-----------------'
c        write(*,'(f9.4)') aver
        end if

	end

	function xinterp2(phi,psi,ngrid,G)  
 	implicit double precision (a-h,o-z)
	dimension G(5000,20),ipo(4)
        DIMENSION C(4)
	
c search for closest gridpoint to (phi,psi).
 	 k=1
         ipo(k)=0
         xmin=1.0e8
	 do i=1,ngrid
          dist=(G(i,1)-phi)*(G(i,1)-phi)+ (G(i,2)-psi)*
     &     (G(i,2)-psi)
          if(dist.le.xmin) then
            ipo(k)=i
            xmin=dist
           end if
          end do
c          write(*,*) xmin,ipo(k)
          if(xmin.le.1.0e-8) go to 3
c search for closest 2 gridpoint to (phi,psi).
        xmin0=xmin
        k=2
 	 ipo(k)=0
         xmin=1.0e8
	 do i=1,ngrid
          dist=(G(i,1)-phi)*(G(i,1)-phi)+ (G(i,2)-psi)*
     &    (G(i,2)-psi)
          if(dist.le.xmin.and.dist.ge.xmin0) then
           if(i.ne.ipo(1)) then
            ipo(k)=i
            xmin=dist
           end if
          end if
         end do
c         write(*,*) xmin,ipo(k)
c search for closest 2 gridpoints to (phi,psi).
        xmin0=xmin
        k=3
 	 ipo(k)=0
         xmin=1.0e8
	 do i=1,ngrid
          dist=(G(i,1)-phi)*(G(i,1)-phi)+ (G(i,2)-psi)*
     &    (G(i,2)-psi)
          if(dist.le.xmin.and.dist.ge.xmin0) then
           x1=G(i,1)
           y1=G(i,2)
           x2=G(ipo(1),1)
           y2=G(ipo(1),2)
           x3=G(ipo(2),1)
           y3=G(ipo(2),2)
           x0=x2*y3+x1*y2+x3*y1-y1*x2-x3*y2-x1*y3
           if(abs(x0).gt.1.0d-8) then 
            ipo(k)=i
            xmin=dist
           end if
          end if
         end do
c         write(*,*) xmin,ipo(k)
C adjust a plane and do interpolation
          x1=G(ipo(3),1)
          y1=G(ipo(3),2)
          z1=G(ipo(3),3)
          z2=G(ipo(1),3)
          z3=G(ipo(2),3)
         xx=x2*y3-x2*y1+x3*y1+x1*y2-x3*y2-x1*y3
         if(abs(xx).lt.1.0d-8) stop 'problem in triangulation'
         c(1)=-(-x3*y1*z2-x1*y2*z3+x3*y2*z1+x1*y3*z2+x2*y1*z3-x2*y3
     &   *z1)/xx
         c(2)=-(y1*z2-y1*z3-y2*z1+y2*z3+y3*z1-y3*z2)/xx
         c(3)=-(-x1*z2+x1*z3+x2*z1-x2*z3-x3*z1+x3*z2)/xx
         x0=c(1)+c(2)*phi+c(3)*psi
       go to 4
3       continue
c       write(*,'(3f9.4)') (G(ipo(1),1,jj), G(ipo(1),2,jj), G(ipo(1),3,jj))
        x0=G(ipo(1),3)
4       continue
c       write(*,'(a22,f9.4)') 'Interpolated J value :', x0
        xinterp=x0
	end

