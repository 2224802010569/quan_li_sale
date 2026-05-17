import os

def extract_flutter_code(project_path, output_file):
    # Các thư mục thường không chứa code logic cần trích xuất
    ignored_dirs = {'.dart_tool', '.git', '.idea', 'build', 'windows', 'android', 'ios', 'linux', 'macos'}
    
    with open(output_file, 'w', encoding='utf-8') as f_out:
        for root, dirs, files in os.walk(project_path):
            # Loại bỏ các thư mục ẩn và thư mục build khỏi danh sách quét
            dirs[:] = [d for d in dirs if d not in ignored_dirs]
            
            for file in files:
                # Chỉ lấy các file mã nguồn Dart
                if file.endswith('.dart'):
                    full_path = os.path.join(root, file)
                    # Tạo đường dẫn tương đối để dễ nhìn hơn
                    relative_path = os.path.relpath(full_path, project_path)
                    
                    f_out.write(f"{'='*80}\n")
                    f_out.write(f"FILE PATH: {relative_path}\n")
                    f_out.write(f"{'='*80}\n\n")
                    
                    try:
                        with open(full_path, 'r', encoding='utf-8') as f_in:
                            content = f_in.read()
                            f_out.write(content)
                    except Exception as e:
                        f_out.write(f"Error reading file: {e}")
                    
                    f_out.write("\n\n")

if __name__ == "__main__":
    # Thay đổi đường dẫn đến thư mục dự án Flutter của bạn
    project_directory = r"C:\Users\HP\Desktop\Save\PTUDDDDNT\quan_li_sale" 
    # Tên file kết quả
    for i in range(1, 100):
        if not os.path.exists(f"extracted_flutter_code_{i}.txt"):
            output_filename = f"extracted_flutter_code_{i}.txt"
            break
    
    if os.path.exists(project_directory):
        print(f"Đang bắt đầu trích xuất code từ: {project_directory}...")
        extract_flutter_code(project_directory, output_filename)
        print(f"Hoàn thành! Code đã được lưu tại: {output_filename}")
    else:
        print("Đường dẫn dự án không tồn tại. Vui lòng kiểm tra lại.")