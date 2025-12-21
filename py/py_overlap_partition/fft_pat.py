import numpy as np
from pathlib import Path


def _is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0


def _bit_reverse_indices(n: int) -> np.ndarray:
    """Return indices for bit-reversal permutation (n must be power of two)."""
    bits = n.bit_length() - 1
    idx = np.arange(n, dtype=np.uint32)
    rev = np.zeros(n, dtype=np.uint32)
    for i in range(bits):
        rev |= ((idx >> i) & 1) << (bits - 1 - i)
    return rev


def float64_to_hex(f):
    """将float64转换为64-bit十六进制字符串"""
    uint64_val = np.uint64(np.frombuffer(np.array([f], dtype=np.float64), dtype=np.uint64)[0])
    return f"{uint64_val:016X}"


def _reorder_cols_stage5(data):
    """
    对row FFT stage 5的结果进行列重排
    每32列为单位，将顺序从 0,1,2,...,15,16,17,...,31
    调整为 0,16,1,17,2,18,...,15,31
    （用于匹配硬件输出的顺序）
    """
    if len(data.shape) != 2:
        return data
    
    rows, cols = data.shape
    if cols != 32:
        return data
    
    reordered = np.zeros_like(data)
    # 创建重排索引：0, 16, 1, 17, 2, 18, ..., 15, 31
    reorder_idx = np.zeros(32, dtype=int)
    for i in range(16):
        reorder_idx[i * 2] = i
        reorder_idx[i * 2 + 1] = i + 16
    
    for i in range(rows):
        reordered[i, :] = data[i, reorder_idx]
    
    return reordered


def _inverse_reorder_cols_stage5(data):
    """
    逆重排函数：将硬件输出的顺序（0,16,1,17,...,15,31）
    转换回正常顺序（0,1,2,...,31）
    （用于在column FFT之前恢复正确的顺序）
    """
    if len(data.shape) != 2:
        return data
    
    rows, cols = data.shape
    if cols != 32:
        return data
    
    restored = np.zeros_like(data)
    # 创建逆重排索引：将 0,16,1,17,...,15,31 映射回 0,1,2,...,31
    # 硬件输出顺序：idx[0]=0, idx[1]=16, idx[2]=1, idx[3]=17, ...
    # 我们需要找到原始位置：original[0]=data[0], original[1]=data[2], original[16]=data[1], ...
    inverse_idx = np.zeros(32, dtype=int)
    for i in range(16):
        inverse_idx[i] = i * 2      # 原始位置 i 在硬件输出中的位置是 i*2
        inverse_idx[i + 16] = i * 2 + 1  # 原始位置 i+16 在硬件输出中的位置是 i*2+1
    
    for i in range(rows):
        restored[i, :] = data[i, inverse_idx]
    
    return restored


def _reorder_rows_stage5(data):
    """
    对column FFT stage 5的结果进行行重排
    每32行为单位，将顺序从 0,1,2,...,15,16,17,...,31
    调整为 0,16,1,17,2,18,...,15,31
    （用于匹配硬件输出的顺序）
    """
    if len(data.shape) != 2:
        return data
    
    rows, cols = data.shape
    if rows != 32:
        return data
    
    reordered = np.zeros_like(data)
    # 创建重排索引：0, 16, 1, 17, 2, 18, ..., 15, 31
    reorder_idx = np.zeros(32, dtype=int)
    for i in range(16):
        reorder_idx[i * 2] = i
        reorder_idx[i * 2 + 1] = i + 16
    
    for j in range(cols):
        reordered[:, j] = data[reorder_idx, j]
    
    return reordered


def _inverse_reorder_rows_stage5(data):
    """
    逆重排函数：将硬件输出的顺序（0,16,1,17,...,15,31）
    转换回正常顺序（0,1,2,...,31）
    （用于在最终输出之前恢复正确的顺序）
    """
    if len(data.shape) != 2:
        return data
    
    rows, cols = data.shape
    if rows != 32:
        return data
    
    restored = np.zeros_like(data)
    # 创建逆重排索引：将 0,16,1,17,...,15,31 映射回 0,1,2,...,31
    inverse_idx = np.zeros(32, dtype=int)
    for i in range(16):
        inverse_idx[i] = i * 2      # 原始位置 i 在硬件输出中的位置是 i*2
        inverse_idx[i + 16] = i * 2 + 1  # 原始位置 i+16 在硬件输出中的位置是 i*2+1
    
    for j in range(cols):
        restored[:, j] = data[inverse_idx, j]
    
    return restored


def _reorder_cols_bitreverse(data):
    """
    对列进行 bit reverse 重排
    将列顺序从 0,1,2,...,31 调整为 bit reverse 顺序：0,16,8,24,...
    （用于匹配硬件输出的 bit reverse 顺序）
    """
    if len(data.shape) != 2:
        return data
    
    rows, cols = data.shape
    if cols != 32:
        return data
    
    reordered = np.zeros_like(data)
    # 使用 bit reverse 索引：0, 16, 8, 24, 4, 20, 12, 28, ...
    bitrev_idx = _bit_reverse_indices(32)
    
    for i in range(rows):
        reordered[i, :] = data[i, bitrev_idx]
    
    return reordered


def save_hex(data, filename):
    """将数据保存为十六进制文本格式"""
    with open(filename, 'w') as f:
        if np.iscomplexobj(data):
            # 复数格式：每行两个十六进制数（real, imag）
            flat = data.flatten()
            for val in flat:
                real_hex = float64_to_hex(np.real(val))
                imag_hex = float64_to_hex(np.imag(val))
                f.write(f"{real_hex} {imag_hex}\n")
        else:
            # 实数格式：每行一个十六进制数
            flat = data.flatten()
            for val in flat:
                hex_val = float64_to_hex(val)
                f.write(f"{hex_val}\n")


def fft_iterative_radix2(x: np.ndarray, stage_callback=None) -> np.ndarray:
    """
    In-place- style iterative radix-2 DIT FFT (forward, matches numpy.fft.fft sign).
    x length must be power of two. Returns complex128.
    
    Args:
        x: 输入数组
        stage_callback: 回调函数，在每一层完成后调用 callback(stage, m, result)
    """
    n = x.shape[0]
    if not _is_power_of_two(n):
        raise ValueError("fft_iterative_radix2 expects power-of-two length.")

    out = np.asarray(x, dtype=np.complex128).copy()
    rev = _bit_reverse_indices(n)
    out[:] = out[rev]  # bit-reversal permutation
    
    # 调用stage 0回调（bit-reversal后）
    if stage_callback:
        stage_callback(0, 0, out.copy())

    m = 2
    stage = 1
    while m <= n:
        half = m // 2
        w_m = np.exp(-2j * np.pi * np.arange(half) / m)
        for k in range(0, n, m):
            u = out[k : k + half].copy()  # 必须copy，避免引用问题
            v = w_m * out[k + half : k + m]
            out[k : k + half] = u + v
            out[k + half : k + m] = u - v
        
        # 调用stage回调
        if stage_callback:
            stage_callback(stage, m, out.copy())
        
        m *= 2
        stage += 1
    return out


def ifft_iterative_radix2(x: np.ndarray) -> np.ndarray:
    """Inverse FFT using conjugate trick on the forward implementation."""
    n = x.shape[0]
    tmp = fft_iterative_radix2(np.conjugate(x))
    return np.conjugate(tmp) / n


def ifft_iterative_radix2_direct(x: np.ndarray, stage_callback=None) -> np.ndarray:
    """
    Direct implementation of iterative radix-2 DIT IFFT (matches hardware implementation).
    This uses the conjugate of FFT twiddle factors, and same data pairing as FFT.
    x length must be power of two. Returns complex128.
    
    Args:
        x: 输入数组
        stage_callback: 回调函数，在每一层完成后调用 callback(stage, m, result)
    
    Note:
        - Twiddle factors: w_m = exp(+2j * pi * k / m) (positive exponent, conjugate of FFT)
        - Data pairing: same as FFT (u = x[k:k+half], v = w_m * x[k+half:k+m])
        - Butterfly: same as FFT (u+v, u-v)
    """
    n = x.shape[0]
    if not _is_power_of_two(n):
        raise ValueError("ifft_iterative_radix2_direct expects power-of-two length.")

    out = np.asarray(x, dtype=np.complex128).copy()
    rev = _bit_reverse_indices(n)
    out[:] = out[rev]  # bit-reversal permutation
    
    # 调用stage 0回调（bit-reversal后）
    if stage_callback:
        stage_callback(0, 0, out.copy())

    m = 2
    stage = 1
    while m <= n:
        half = m // 2
        # IFFT twiddle: positive exponent (conjugate of FFT twiddle)
        # w_m = exp(+2j * pi * k / m) = conjugate(exp(-2j * pi * k / m))
        w_m = np.exp(+2j * np.pi * np.arange(half) / m)
        for k in range(0, n, m):
            u = out[k : k + half].copy()  # 必须copy，避免引用问题
            v = w_m * out[k + half : k + m]  # Same data pairing as FFT
            out[k : k + half] = u + v  # Same butterfly as FFT
            out[k + half : k + m] = u - v
        
        # 每个 stage 结束后都除以 2（匹配硬件实现）
        # 对于 32 点 IFFT，有 5 个 stage，每个 stage 除以 2，总共除以 2^5 = 32
        out = out / 2.0
        
        # 调用stage回调（在除以 2 之后，保存已归一化的结果）
        if stage_callback:
            stage_callback(stage, m, out.copy())
        
        m *= 2
        stage += 1
    
    # 不再需要最后除以 n，因为每个 stage 都已经除以 2 了
    # 对于 n=32，5 个 stage 各除以 2，总共除以 2^5 = 32，等价于最后除以 n
    return out


def fft2d_iterative_radix2(mat: np.ndarray, save_intermediate: bool = False,
                         output_dir: Path = None) -> np.ndarray:
    """
    2D FFT via row FFT then column FFT; both dimensions must be powers of two.

    Args:
        mat: 输入矩阵
        save_intermediate: 是否保存中间结果
        output_dir: 输出目录
    """
    m, n = mat.shape
    if not _is_power_of_two(m) or not _is_power_of_two(n):
        raise ValueError("fft2d_iterative_radix2 expects power-of-two dimensions.")

    out = np.asarray(mat, dtype=np.complex128).copy()
    
    # Row FFT: 对每一行执行FFT，并在每一层完成后保存整个矩阵
    for stata in ["row", "col"]:
        if save_intermediate and output_dir:
            # 用于跟踪每一层完成的行的数量
            row_stage_count = {}
            # 用于存储每一层的结果，确保保存的是正确的数据
            row_stage_results = {}
            
            # 对每一行执行FFT
            for i in range(m):
                def make_row_callback(row_idx):
                    def callback(stage, m_val, row_result):
                        nonlocal out, row_stage_count, row_stage_results
                        # 检查是否所有行都完成了当前层
                        if stage not in row_stage_count:
                            row_stage_count[stage] = 0
                            row_stage_results[stage] = out.copy()  # 保存当前矩阵状态
                        
                        # 更新该行的数据到临时矩阵
                        row_stage_results[stage][row_idx, :] = row_result
                        row_stage_count[stage] += 1
                        
                        # 当所有行都完成当前层时，保存整个矩阵
                        if row_stage_count[stage] == m:
                            if stage == 0:
                                filename = output_dir / f"{stata}_fft_stage0_bitreversed.hex"
                            else:
                                filename = output_dir / f"{stata}_fft_stage{stage}_m{m_val}.hex"
                            
                            # 对stage 5进行列重排
                            data_to_save = row_stage_results[stage]
                            if stage == 5:
                                data_to_save = _reorder_cols_stage5(data_to_save)
                            
                            # 保存该层完成时的矩阵状态
                            save_hex(data_to_save, filename)
                            # 更新out矩阵为当前层的结果（不重排，保持原始顺序）
                            out[:] = row_stage_results[stage]
                            row_stage_count[stage] = 0  # 重置计数器
                    return callback
                
                out[i, :] = fft_iterative_radix2(out[i, :], stage_callback=make_row_callback(i))
        else:
            # 不保存中间结果，直接执行
            for i in range(m):
                out[i, :] = fft_iterative_radix2(out[i, :])
        out = out.T

    

    # 保存最终结果
    if save_intermediate and output_dir:
        save_hex(out, output_dir / "final_output.hex")
    
    return out


def ifft2d_iterative_radix2(mat: np.ndarray, save_intermediate: bool = False,
                            output_dir: Path = None) -> np.ndarray:
    """
    2D IFFT via row IFFT then column IFFT; both dimensions must be powers of two.

    Args:
        mat: 输入矩阵
        save_intermediate: 是否保存中间结果
        output_dir: 输出目录
    """
    m, n = mat.shape
    if not _is_power_of_two(m) or not _is_power_of_two(n):
        raise ValueError("ifft2d_iterative_radix2 expects power-of-two dimensions.")

    out = np.asarray(mat, dtype=np.complex128).copy()
    
    # Row IFFT: 对每一行执行IFFT，并在每一层完成后保存整个矩阵
    for stata in ["row", "col"]:
        # 确定当前要处理的行/列数
        if stata == "row":
            num_items = m
        else:  # col (after transpose, rows become columns)
            num_items = m  # After transpose, m rows become m columns
        
        if save_intermediate and output_dir:
            # 用于跟踪每一层完成的行的数量
            col_stage_count = {}
            # 用于存储每一层的结果，确保保存的是正确的数据
            col_stage_results = {}
            
            # 对每一行/列执行IFFT
            for i in range(num_items):
                def make_col_callback(col_idx):
                    def callback(stage, m_val, col_result):
                        nonlocal out, col_stage_count, col_stage_results
                        # 注意：col_result 是 ifft_iterative_radix2_direct 在 stage callback 时传递的
                        # 现在每个 stage 结束后都除以 2，所以 col_result 是已归一化的（每个 stage 都除以 2）
                        
                        # 检查是否所有行/列都完成了当前层
                        if stage not in col_stage_count:
                            col_stage_count[stage] = 0
                            col_stage_results[stage] = out.copy()  # 保存当前矩阵状态
                        
                        # 更新该行/列的数据到临时矩阵（使用已归一化的 col_result，每个 stage 都除以 2）
                        if stata == "row":
                            col_stage_results[stage][col_idx, :] = col_result
                        else:  # col (after transpose, we operate on rows, which are the original columns)
                            col_stage_results[stage][col_idx, :] = col_result
                        col_stage_count[stage] += 1
                        
                        # 当所有行/列都完成当前层时，保存整个矩阵
                        if col_stage_count[stage] == num_items:
                            if stage == 0:
                                filename = output_dir / f"{stata}_ifft_stage0_bitreversed.hex"
                            else:
                                filename = output_dir / f"{stata}_ifft_stage{stage}_m{m_val}.hex"
                            
                            data_to_save = col_stage_results[stage]
                            if stage == 5:
                                if stata == "row":
                                    data_to_save = _reorder_cols_stage5(data_to_save)
                                else:  # col
                                    data_to_save = _reorder_rows_stage5(data_to_save)
                            
                            # stage 0 进行列 bit reverse 重排（匹配硬件输出顺序：0,16,8,24,...）
                            if stage == 0 and stata == "col":
                                data_to_save = _reorder_cols_bitreverse(data_to_save)
                            
                            if stata == "col":  # Only transpose for column IFFT when saving
                                data_to_save = data_to_save.T
                            
                            # 保存该层完成时的矩阵状态（每个 stage 都已除以 2）
                            save_hex(data_to_save, filename)
                            # 更新 out 矩阵，使用已归一化的结果
                            out[:] = col_stage_results[stage]
                            col_stage_count[stage] = 0
                    return callback
                
                if stata == "row":
                    out[i, :] = ifft_iterative_radix2_direct(out[i, :], stage_callback=make_col_callback(i))
                else:  # col (after transpose, operate on rows)
                    out[i, :] = ifft_iterative_radix2_direct(out[i, :], stage_callback=make_col_callback(i))
        else:
            # 不保存中间结果，直接执行
            for i in range(num_items):
                if stata == "row":
                    out[i, :] = ifft_iterative_radix2_direct(out[i, :])
                else:  # col (after transpose, operate on rows)
                    out[i, :] = ifft_iterative_radix2_direct(out[i, :])
        
        # 在 row IFFT 后转置，以便进行 column IFFT
        if stata == "row":
            out = out.T
    
    # Column IFFT 完成后，需要再转置回来
    out = out.T
    
    # 保存最终结果
    if save_intermediate and output_dir:
        save_hex(out, output_dir / "final_output_ifft.hex")
    
    return out


def print_twiddle_pairing(n=32, mode="FFT"):
    """
    打印每个 stage 的 twiddle factor 配对列表
    
    Args:
        n: FFT点数（必须是2的幂）
        mode: "FFT" 或 "IFFT"
    """
    if not _is_power_of_two(n):
        raise ValueError(f"n must be power of two, got {n}")
    
    stages = []
    m = 2
    while m <= n:
        stages.append(m)
        m *= 2
    
    print(f"\n{'='*80}")
    print(f"{mode} Twiddle Factor Pairing for {n}-point FFT")
    print(f"{'='*80}\n")
    
    addr = 0
    for stage_idx, m in enumerate(stages):
        half = m // 2
        if mode == "FFT":
            w_m = np.exp(-2j * np.pi * np.arange(half) / m)
        else:  # IFFT
            w_m = np.exp(+2j * np.pi * np.arange(half) / m)
        
        print(f"Stage {stage_idx + 1} (m={m}, half={half}):")
        print(f"  Twiddle factors (ROM address {addr} to {addr + half - 1}):")
        
        for k in range(half):
            w = w_m[k]
            angle = np.angle(w) * 180 / np.pi
            print(f"    k={k:2d}: w_{m}^{k} = {w.real:8.5f} + {w.imag:8.5f}j = exp({angle:+7.2f}°) [ROM addr {addr + k}]")
        
        print(f"\n  Data pairing pattern (for each butterfly group of size {m}):")
        print(f"    For k = 0, {m}, {2*m}, ..., {n-m}:")
        print(f"      Butterfly group: indices [k, k+1, ..., k+{m-1}]")
        print(f"      - u (upper half): indices [k, k+1, ..., k+{half-1}]")
        print(f"      - v (lower half): indices [k+{half}, k+{half+1}, ..., k+{m-1}]")
        print(f"      - Twiddle applied to v:")
        for k in range(min(4, half)):  # 只显示前4个作为示例
            print(f"          v[k+{half}+{k}] *= w_{m}^{k} (ROM addr {addr + k})")
        if half > 4:
            print(f"          ... (共 {half} 个 twiddle factors)")
        print()
        
        addr += half
    
    print(f"{'='*80}")
    print(f"Total twiddle factors: {addr}")
    print(f"{'='*80}\n")


def generate_twiddle_factors(n=32, output_dir: Path = None):
    """
    生成32点FFT的twiddle factor文件
    
    Args:
        n: FFT点数（必须是2的幂）
        output_dir: 输出目录
    """
    if not _is_power_of_two(n):
        raise ValueError(f"n must be power of two, got {n}")
    
    stages = []
    m = 2
    while m <= n:
        stages.append(m)
        m *= 2
    
    # 生成twiddle factor文件
    twiddle_file = output_dir / "twiddle_factors.hex"
    with open(twiddle_file, 'w') as f:
        addr = 0
        for stage_idx, m in enumerate(stages):
            half = m // 2
            w_m = np.exp(-2j * np.pi * np.arange(half) / m)
            
            for k in range(half):
                real_hex = float64_to_hex(np.real(w_m[k]))
                imag_hex = float64_to_hex(np.imag(w_m[k]))
                f.write(f"{real_hex} {imag_hex}\n")
                addr += 1
    
    print(f"Generated twiddle factors: {twiddle_file}")
    print(f"  Total twiddle factors: {addr} (for {n}-point FFT)")
    return twiddle_file


def demo_compare_32x32():
    """Run a quick 32x32 complex test and compare to numpy.fft as golden data."""
    import shutil
    
    # 获取当前脚本所在目录
    script_dir = Path(__file__).resolve().parent
    # output fi;e：../../sim/fft_pat
    output_dir = script_dir.parent.parent / "sim" / "fft_pat"
    
    rng = np.random.default_rng(0)
    # FFT输入应该是实数，虚部为0
    mat = rng.standard_normal((32, 32)) + 0j  # 只有实部，虚部为0

    # 创建输出目录（清理旧的hex文件，但保留其他文件）
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 清理旧的hex文件
    for old_file in output_dir.glob("*.hex"):
        old_file.unlink()

    print("=" * 70)
    print("Generating 32x32 test matrix")
    print("=" * 70)
    print(f"Input shape: {mat.shape}")
    print(f"Input dtype: {mat.dtype}")
    
    # 保存输入数据
    print("\nSaving input data...")
    save_hex(mat, output_dir / "input.hex")
    
    # 执行2D FFT并保存中间结果
    print("\nExecuting 2D FFT with intermediate results...")
    print("  - Row FFT: 6 stages (stage0 + 5 layers)")
    print("  - Column FFT: 6 stages (stage0 + 5 layers)")
    print("  - Each stage saves complete 32×32 matrix")
    
    ours = fft2d_iterative_radix2(mat, save_intermediate=True, output_dir=output_dir)
    
    # 验证结果
    golden = np.fft.fft2(mat)
    max_err = np.max(np.abs(ours - golden))
    mean_err = np.mean(np.abs(ours - golden))
    rel_err = np.max(np.abs(ours - golden) / (np.abs(golden) + 1e-15))
    
    print(f"\n" + "=" * 70)
    print("Golden Test Verification (FFT)")
    print("=" * 70)
    print(f"Max absolute error vs numpy.fft.fft2: {max_err:.3e}")
    print(f"Mean absolute error: {mean_err:.3e}")
    print(f"Max relative error: {rel_err:.3e}")
    
    # Check if results match
    if np.allclose(ours, golden, rtol=1e-10, atol=1e-10):
        print("\n✓ PASS: Our FFT result matches numpy.fft.fft2 (Golden Test)")
        print("  All values are within numerical precision tolerance")
    else:
        print("\n✗ FAIL: Our FFT result does NOT match numpy.fft.fft2")
        print("  Results differ beyond numerical precision tolerance")
    
    print("=" * 70)
    
    # 执行2D IFFT并保存中间结果
    print("\nExecuting 2D IFFT with intermediate results...")
    print("  - Row IFFT: 6 stages (stage0 + 5 layers)")
    print("  - Column IFFT: 6 stages (stage0 + 5 layers)")
    print("  - Each stage saves complete 32×32 matrix")
    
    # 使用 FFT 的结果作为 IFFT 的输入（验证 round-trip）
    ifft_input = ours.copy()
    
    # 保存 IFFT 的输入数据（FFT 的输出）
    # 注意：IFFT 的输入应该是 FFT 的输出（频域数据）
    print("\nSaving IFFT input data (FFT output)...")
    save_hex(ifft_input, output_dir / "input_ifft.hex")
    
    ours_ifft = ifft2d_iterative_radix2(ifft_input, save_intermediate=True, output_dir=output_dir)
    
    # 验证 IFFT 结果（应该恢复原始输入）
    golden_ifft = np.fft.ifft2(ifft_input)
    max_err_ifft = np.max(np.abs(ours_ifft - golden_ifft))
    mean_err_ifft = np.mean(np.abs(ours_ifft - golden_ifft))
    rel_err_ifft = np.max(np.abs(ours_ifft - golden_ifft) / (np.abs(golden_ifft) + 1e-15))
    
    print(f"\n" + "=" * 70)
    print("Golden Test Verification (IFFT)")
    print("=" * 70)
    print(f"Max absolute error vs numpy.fft.ifft2: {max_err_ifft:.3e}")
    print(f"Mean absolute error: {mean_err_ifft:.3e}")
    print(f"Max relative error: {rel_err_ifft:.3e}")
    
    # Check if results match
    if np.allclose(ours_ifft, golden_ifft, rtol=1e-10, atol=1e-10):
        print("\n✓ PASS: Our IFFT result matches numpy.fft.ifft2 (Golden Test)")
        print("  All values are within numerical precision tolerance")
    else:
        print("\n✗ FAIL: Our IFFT result does NOT match numpy.fft.ifft2")
        print("  Results differ beyond numerical precision tolerance")
    
    print("=" * 70)
    
    # 生成twiddle factor文件
    print("\nGenerating twiddle factors...")
    generate_twiddle_factors(n=32, output_dir=output_dir)
    
    print("\n" + "=" * 70)
    print("Summary")
    print("=" * 70)
    print(f"All hex files saved to: {output_dir.absolute()}")
    print("\nFile structure:")
    print("  input.hex                          - Input matrix (32×32)")
    print("  row_fft_stage0_bitreversed.hex    - After bit-reversal (32×32)")
    print("  row_fft_stage1_m2.hex             - After stage 1, m=2 (32×32)")
    print("  row_fft_stage2_m4.hex             - After stage 2, m=4 (32×32)")
    print("  row_fft_stage3_m8.hex             - After stage 3, m=8 (32×32)")
    print("  row_fft_stage4_m16.hex            - After stage 4, m=16 (32×32)")
    print("  row_fft_stage5_m32.hex            - After stage 5, m=32 (32×32)")
    print("  after_row_fft.hex                 - After all row FFTs (32×32)")
    print("  col_fft_stage0_bitreversed.hex   - After bit-reversal (32×32)")
    print("  col_fft_stage1_m2.hex            - After stage 1, m=2 (32×32)")
    print("  col_fft_stage2_m4.hex            - After stage 2, m=4 (32×32)")
    print("  col_fft_stage3_m8.hex            - After stage 3, m=8 (32×32)")
    print("  col_fft_stage4_m16.hex           - After stage 4, m=16 (32×32)")
    print("  col_fft_stage5_m32.hex           - After stage 5, m=32 (32×32)")
    print("  final_output.hex                 - Final 2D FFT result (32×32)")
    print("  twiddle_factors.hex              - Twiddle factors for 32-point FFT")
    print("\nTotal files: 1 (input) + 6 (row stages) + 1 (after_row) + 6 (col stages) + 1 (final) + 1 (twiddle) = 16 files")
    print("Each matrix file contains complete 32×32 matrix (1024 complex numbers = 2048 fp64 values)")
    print("Twiddle factor file contains 31 twiddle factors (1+2+4+8+16 for 5 stages)")


if __name__ == "__main__":
    demo_compare_32x32()
