Clone về rồi tạo thêm 1 file application-local.properties trong thư mục kawaiienglish/src/main/resources/

dán code này vào:
spring.datasource.password=mat_khau_cua_binh_minh

(thay mật khẩu mysql root của m vào)

chạy mvn clean install, vào file KawaiienglishApplication.java rồi bấm run thôi

các link để check:
http://localhost:8080/ (tạm thời hiện thông báo lỗi)
http://localhost:8080/api/ping (hiển thị thông báo chào mừng)
