a<-10
a+5

vec2<-c(1,2,9,0,3,5,23)

sort(vec2)
sort(vec2,decreasing = TRUE)

seq_vec<- c(seq(2,8,by=3),seq(12,18,by=3))
print(seq_vec)

rep_vec <-rep(rep(c(1,2,3),times=3))
print(rep_vec)


rep_vec2<-rep(c(1,2,3,4),times=c(1:4))

mat<-matrix(1:9,nrow=3,ncol=3)

seq<-seq(10,26,by=2)
mat1<-matrix((seq),nrow=3,ncol=3,byrow = TRUE)

rownames(mat1)<-c("Row1","Row2","Row3")
colnames(mat1)<-c("Col1","Col2","Col3")

mat1[c(1,3),c(1,3)] #here mat1[row part, col part]
mat1[2,] #blank means all col
mat[,2] #blank means all row

mat2<-matrix(1:4,nrow=2)
mat3<-matrix(5:8,nrow=2)

sum_mat<-mat2+mat3
sub_mat<-mat2-mat3
mul1_mat<-mat2*mat3 #Element wise multiplication
mul_mat<-mat2%*%mat3 #dot product
div_mat<-mat2/mat3

#Transpose of matrix : t()

t_mat<-t(mat)

#Inverse Matrix : solve()

inv_mat2<-solve(mat2)

#Array

arr<-array(1:18,dim=c(3,3,2)) #here, dim=c(row_no,col_num,No_of_Matrix)




