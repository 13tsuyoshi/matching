function deferred_acceptance(m_prefs::Array{Int64},f_prefs::Array{Int64})
m_prefs = m_prefs
f_prefs = f_prefs

m_prefs = m_prefs'
f_prefs = f_prefs'    

m_size = size(m_prefs, 1)#男の数
f_size = size(f_prefs, 1)#女の数
is_single_prop = ones(Bool,m_size)#男たちが独身かどうか。０なら独身でない１なら独身
next_resp = ones(Int,m_size)#各人の男たちにとって次求婚する女の順位（最初は皆一番好きな女からアッタクしていく）
current_prop = zeros(Int,f_size)#暫定的にマッチングしてる女各人にとっての男たちのリスト。
while sum(is_single_prop) != 0#独身の男たちがいる間は
    for m in 1:m_size#男の数分全員考える
            if is_single_prop[m]#もしmが独身なら（１なら）
                f = m_prefs[m, next_resp[m]]  # 次求婚する女に求婚する
                if f == 0# 次求婚する女がマッチングしなかった時の状態の女だったらつまり誰とも結婚したくなかったら
                is_single_prop[m] = false#独身とみなさない #Falseではダメ
                elseif (find(f_prefs[f,:].==m) .< find(f_prefs[f,:].==current_prop[f])) == trues(1)#fに取ってmが今の彼氏よりもよかったら
                    if current_prop[f] != 0#もしfに付き合っていた人がいたら
                        is_single_prop[current_prop[f]] = true#fのもと交際相手の男が独身になる
                    end
                    current_prop[f] = m#fの付き合っている人をmにする
                    is_single_prop[m] = false#mを独身でなくさせる
                next_resp[m] += 1#次の求婚対象の女を次の順位の女にする
                end
            end
    end
end
    
m_matched = Array(Int64,m_size)
for m in 1:m_size
    m_matched[m]= m_prefs[m,next_resp[m]-1]
end
f_matched = current_prop
    
    return m_matched,f_matched
end