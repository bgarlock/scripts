if($_SERVER['PHP_AUTH_USER']!='' && $_SERVER['PHP_AUTH_PW']!='' && $_SESSION['memberID']!=$_SERVER['PHP_AUTH_USER'] && !$_GET['loginFailed']){
       $_POST['signIn']=1;
       $_POST['username']=$_SERVER['PHP_AUTH_USER'];
       $_POST['password']=$_SERVER['PHP_AUTH_PW'];
}